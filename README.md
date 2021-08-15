# TDLibFramework

[![CI](https://github.com/Swiftgram/TDLibFramework/actions/workflows/ci.yml/badge.svg)](https://github.com/Swiftgram/TDLibFramework/actions/workflows/ci.yml)

Project contains pre-compiled [TDLib](https://github.com/tdlib/td) binary for iOS, macOS, watchOS, tvOS and simulators in `.xcframework` bundle.

If you're looking for pure Swift library, check out [TDLibKit](https://github.com/Swiftgram/TDLibKit)

## Installation
### Xcode
1. Install Xcode 12.5+
2. Add `https://github.com/Swiftgram/TDLibFramework` as SPM dependency in `Project > Swift Packages`. 
This could take a while cause it downloads ~300mb zip file with xcframework.
3. Add `arm64` to `EXCLUDED_ARCHS` due to lack of [arm64 support](#m1-support) or use `ONLY_ACTIVE_ARCH=YES` for debug builds on Intel CPU.
4. Add `TDLibFramework` as your target dependency.
5. Add `libz.1.tbd` and `libc++.1.tbd` as your target dependencies.
6. If something is not accesible from TDLibFramework, make sure to add `libSystem.B.tbd` for all platforms and `libc++abi.tbd` if you're building non-macOS app. [Source](https://github.com/modestman/tdlib-swift/blob/master/td-xcframework/td.xcodeproj/project.pbxproj#L301)
7. Code!
### Flutter
See [Wiki page](https://github.com/Swiftgram/TDLibFramework/wiki/CocoaPods-&-Flutter)


## Usage
### Create client
```swift
let client: UnsafeMutableRawPointer! = td_json_client_create()
```
### Make request object
```swift
let request = ["@type": "getTextEntities", "text": "@telegram /test_command https://telegram.org telegram.me", "@extra": ["5", 7.0, "\\u00e4"]] as [String: Any]
```

### JSON Serialization and Deserialization
Small example for helper functions you will need to talk with TDLib
```swift
func dictToJSONString(_ dictionary: [String: Any]) -> String {
    let dictionaryData = try! JSONSerialization.data(withJSONObject: dictionary)
    return String(data: dictionaryData, encoding: .utf8)!
}

func JSONStringToDict(_ string: String) -> [String: Any] {
    let responseData = string.data(using: .utf8)!
    return try! JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String: Any]
}
```

### Synchronious requests
Only for methods with "[Can be called synchronously](https://github.com/tdlib/td/blob/73d8fb4b3584633b0ffde97a20bbff6602e7a5c4/td/generate/scheme/td_api.tl#L4294)" in docs
```swift
if let res = td_json_client_execute(client, dictToJSONString(request)) {
    let responseString = String(cString: res)
    let responseDict = JSONStringToDict(responseString)
    print("Response from TDLib \(responseDict)")
}
```

### Async requests
```swift
let request = ["@type": "setTdlibParameters",
                "parameters": [
                    "database_directory": "tdlib",
                    "use_message_database": true,
                    "use_secret_chats": true,
                    "api_id": 94575,
                    "api_hash": "a3406de8d171bb422bb6ddf3bbd800e2",
                    "system_language_code": "en",
                    "device_model": "Desktop",
                    "application_version": "1.0",
                    "enable_storage_optimizer": true
                    ]
                ] as [String : Any]

// Send request
td_json_client_send(client, dictToJSONString(request))

// Block thread and wait for response (not more 5.0 seconds)
if let response = td_json_client_receive(client, 5.0) {
   let responseString = String(cString: res)
   let responseDict = JSONStringToDict(responseString)
   print("Async response from TDLib \(responseDict)")
}
```

Destroy client on exit
```swift
td_json_client_destroy(client)
```


## Releases
You can find latest releases at [Releases](https://github.com/Swiftgram/TDLibFramework/releases) page.


## Build
You can find more about build process in [Github Actions](.github/workflows/ci.yml) file.


## TODO
- [ ] Lib tests on watchOS simulator


## M1 Support
> There is PR in [tdlib repo](https://github.com/tdlib/td/pull/1620) to support Apple Silicon.

Apple Silicon is not supported due to lack of Python 2 support in [Python-Apple-Support](https://github.com/beeware/Python-Apple-support) (thus [TDLib](https://github.com/tdlib/td)) can't be compiled natively on arm64 Macs.

If you want to build on M1, please run Xcode under Apple Rosetta 2

More info in this [Telegram thread](https://t.me/tdlibchat/17955)

## Credits
- Anton Glezman for [Build Guide](https://github.com/modestman/tdlib-swift) and basic implementation
- Telegram Team for [TDLib](https://github.com/tdlib/td)


## License
[MIT](LICENSE)
