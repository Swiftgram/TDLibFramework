import XCTest
@testable import TDLibFramework

func dictToJSONString(_ dictionary: [String: Any]) -> String {
    let dictionaryData = try! JSONSerialization.data(withJSONObject: dictionary)
    return String(data: dictionaryData, encoding: .utf8)!
}

func JSONStringToDict(_ string: String) -> [String: Any] {
    let responseData = string.data(using: .utf8)!
    return try! JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String: Any]
}

/// Thread safe one shot flag which stops the update receiver thread.
private final class StopFlag {
    private let lock = NSLock()
    private var stopped = false

    var isStopped: Bool {
        lock.lock()
        defer { lock.unlock() }
        return stopped
    }

    func stop() {
        lock.lock()
        stopped = true
        lock.unlock()
    }
}

final class TDLibFrameworkTests: XCTestCase {
    func testOffline() {
        let _: Int32 = td_create_client_id()
        let request = ["@type": "getTextEntities", "text": "@telegram /test_command https://telegram.org telegram.me", "@extra": ["5", 7.0, "\\u00e4"] as [Any]] as [String: Any]
        
        if let res = td_execute(dictToJSONString(request)) {
            let responseString = String(cString: res)
            let responseDict = JSONStringToDict(responseString)
            print("Response from TDLib \(responseDict)")
            XCTAssertEqual((responseDict["@extra"] as! [Any]).count, (request["@extra"] as! [Any]).count)
            XCTAssertEqual((responseDict["entities"] as! [Any]).count, 4)
        } else {
            preconditionFailure("No result for td_json_client_execute")
        }
    }
    func testLogin() {
        let clientId: Int32 = td_create_client_id()
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            XCTFail("Unable to get cache path")
            return
        }
        let tdlibPath = cachesUrl.appendingPathComponent("tdlib", isDirectory: true).path
        // TDLib logs to stderr, which on CI goes through the simulator log pipeline. Higher verbosity
        // levels flood it with megabytes of logs, stall the threads that write them (the updates and
        // responses are sent right after the corresponding log line) and slow the receiver down to a
        // crawl, so keep only errors here.
        let logVerbosityRequest = ["@type": "setLogVerbosityLevel", "new_verbosity_level": 1] as [String : Any]
        let request = [
            "@type": "setTdlibParameters",
            "api_hash": "5e6d7b36f0e363cf0c07baf2deb26076",
            "api_id": 287311,
            "application_version": "1.0",
            "database_directory": tdlibPath,
            "database_encryption_key": nil ?? NSNull(),
            "device_model": "iOS",
            "enable_storage_optimizer": true,
            "files_directory": "",
            "ignore_file_names": true,
            "system_language_code": "en",
            "system_version": "Unknown",
            "use_chat_info_database": true,
            "use_file_database": true,
            "use_message_database": true,
            "use_secret_chats": true,
            "use_test_dc": false,
            "@extra": "setTdlibParameters-request-1"
        ] as [String: Any]
        
        let setTdlibParametersExpectation = XCTestExpectation(description: "TdlibParameters set sucesfully")
        // Create an expectation with a description
        let authStateExpectation = XCTestExpectation(description: "Recieved authorizationStateWaitPhoneNumber auth state")

        // Receive on a dedicated thread: `td_receive` blocks, and threads with a low QoS are starved
        // exactly when TDLib is busy. The loop must also be able to stop, otherwise it keeps receiving
        // for the rest of the test run.
        let stopFlag = StopFlag()
        let receiverThread = Thread {
            while !stopFlag.isStopped {
                guard let res = td_receive(1.0) else {
                    continue
                }
                let responseDict = JSONStringToDict(String(cString: res))
                // Nothing but responses is interesting here, and printing every update would only
                // slow the receiver down.
                guard let extra = responseDict["@extra"] as? String else {
                    continue
                }
                switch (extra) {
                case "setTdlibParameters-request-1":
                    XCTAssertEqual(responseDict["@type"] as? String, "ok")
                    td_send(
                        clientId,
                        dictToJSONString(
                            [
                                "@type": "getAuthorizationState",
                                "@extra": "getAuthorizationState-request-1"
                            ] as [String: Any]
                        )
                    )
                    setTdlibParametersExpectation.fulfill()
                case "getAuthorizationState-request-1":
                    XCTAssertEqual(responseDict["@type"] as? String, "authorizationStateWaitPhoneNumber")
                    authStateExpectation.fulfill()
                default:
                    break
                }
            }
        }
        receiverThread.name = "app.swiftgram.TDLibFramework.receiver"
        receiverThread.start()
                
        if let res = td_execute(dictToJSONString(logVerbosityRequest)) {
            let responseString = String(cString: res)
            let responseDict = JSONStringToDict(responseString)
            XCTAssertEqual(responseDict["@type"] as? String, "ok")
        } else {
            preconditionFailure("logVerbosityRequest: No result for td_json_client_execute")
        }
        td_send(clientId, dictToJSONString(request))
        
        // Wait for the expectation to be fulfilled
        wait(for: [setTdlibParametersExpectation, authStateExpectation], timeout: 120.0)
        stopFlag.stop()
    }
}
