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

final class TDLibFrameworkTests: XCTestCase {
    func testOffline() {
        let client: UnsafeMutableRawPointer! = td_json_client_create()
        let request = ["@type": "getTextEntities", "text": "@telegram /test_command https://telegram.org telegram.me", "@extra": ["5", 7.0, "\\u00e4"]] as [String: Any]
        
        if let res = td_json_client_execute(client, dictToJSONString(request)) {
            let responseString = String(cString: res)
            let responseDict = JSONStringToDict(responseString)
            print("Response from TDLib \(responseDict)")
            XCTAssertEqual((responseDict["@extra"] as! [Any]).count, (request["@extra"] as! [Any]).count)
            XCTAssertEqual((responseDict["entities"] as! [Any]).count, 4)
        } else {
            preconditionFailure("No result for td_json_client_execute")
        }
        
        td_json_client_destroy(client)
    }
    func testLogin() {
        let client: UnsafeMutableRawPointer! = td_json_client_create()
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            XCTFail("Unable to get cache path")
            return
        }
        let tdlibPath = cachesUrl.appendingPathComponent("tdlib", isDirectory: true).path
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
        
        // Define a global dispatch queue
        let backgroundQueue = DispatchQueue(label: "app.swiftgram.TDLibFramework.backgroundQueue", qos: .background)
        
        backgroundQueue.async {
            while true {
                if let res = td_json_client_receive(client, 5) {
                    let responseString = String(cString: res)
                    let responseDict = JSONStringToDict(responseString)
                    print("Response from TDLib \(responseDict)")
                    if let extra = responseDict["@extra"] as? String {
                        print("@extra value \(extra)")
                        switch (extra) {
                        case "setTdlibParameters-request-1":
                            td_json_client_send(
                                client,
                                dictToJSONString(
                                    [
                                        "@type": "getAuthorizationState",
                                        "@extra": "getAuthorizationState-request-1"
                                    ] as [String: Any]
                                )
                            )
                            setTdlibParametersExpectation.fulfill()
                        case "getAuthorizationState-request-1":
                            XCTAssertEqual(responseDict["@type"] as! String,  "authorizationStateWaitPhoneNumber")
                            authStateExpectation.fulfill()
                        default:
                            break
                        }
                    }
                }
                // Sleep for a short interval to avoid busy-waiting
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        
        td_json_client_send(client, dictToJSONString(request))
        
        // Wait for the expectation to be fulfilled
        wait(for: [setTdlibParametersExpectation, authStateExpectation], timeout: 180.0)
        
    }
}
