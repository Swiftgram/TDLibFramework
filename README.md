# TDLibFramework

[![CI](https://github.com/Swiftgram/TDLibFramework/actions/workflows/ci.yml/badge.svg)](https://github.com/Swiftgram/TDLibFramework/actions/workflows/ci.yml)

Project builds and bundles [TDLib](https://github.com/tdlib/td) for iOS, macOS, watchOS, tvOS and simulators in `.xcframework`

### Releases
You can find latest release at [Releases](https://github.com/Swiftgram/TDLibFramework/releases) page.

You can request tdlib version update with [Issue](https://github.com/Swiftgram/TDLibFramework/issues)


### Build
You can find more about build process in [Build Docs](BUILD.md)


### TODO
- [ ] Auto release from GH actions
- [ ] Lib tests on simulators
- [ ] SPM with .xcframework binary ([Docs](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages))
- [ ] Build docs
- [ ] Links to M1 issues


### M1 Support
Apple Silicon is not supported due to lack of Python 2 support in [Python-Apple-Support](https://github.com/beeware/Python-Apple-support) (thus [TDLib](https://github.com/tdlib/td)) can't be compiled natively on arm64 Macs.

If you want to run on M1, please run Xcode under Apple Rosetta 2

### Credits
- Anton Glezman for [Build Guide](https://github.com/modestman/tdlib-swift) and basic implementation
- Telegram Team for [TDLib](https://github.com/tdlib/td)


### License
[MIT](LICENSE)
