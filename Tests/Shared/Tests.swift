import TDLibFramework
import XCTest

#if os(iOS)
@testable import iOSApp
#elseif os(macOS)
@testable import macOSApp
#elseif os(watchOS)
@testable import watchOSApp_WatchKit_Extension
#elseif os(tvOS)
@testable import tvOSApp
#endif

func dictToJSONString(_ dictionary: [String: Any]) -> String {
    let dictionaryData = try! JSONSerialization.data(withJSONObject: dictionary)
    return String(data: dictionaryData, encoding: .utf8)!
}

func JSONStringToDict(_ string: String) -> [String: Any] {
    let responseData = string.data(using: .utf8)!
    return try! JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String: Any]
}

final class TDLibFrameworkTests: XCTestCase {
    func testExample() {
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
}
