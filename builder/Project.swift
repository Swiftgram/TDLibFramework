import ProjectDescription

import Foundation

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}

let rootPath = ".."
let tdPath = "\(rootPath)/td"
let tdIOSPath = "\(tdPath)/example/ios"

func getVersion() -> String {
    let td_git_tag = shell("cd \(tdPath) && git rev-parse --short=8 HEAD")
    var version = shell("python3 \(rootPath)/scripts/extract_td_version.py \(tdPath)/td/telegram/Td.h").trimmingCharacters(in: .whitespacesAndNewlines)

    if version.isEmpty {
        version = td_git_tag
    } else {
        version = "\(version)-\(td_git_tag)"
    }

    print("TD version: \(version)")
    return version
}

let SimulatorSuffix = "-simulator"



func getBuildPlatforms() -> [String] {
  return Environment.platform.getString(default: "iOS,iOS-simulator,macOS,watchOS,watchOS-simulator,tvOS,tvOS-simulator").components(separatedBy: ",")
}

let BuildPlatforms = getBuildPlatforms()
print("\nGenerating project for platforms \(BuildPlatforms)")

func platformFromString(_ platformString: String) -> Platform {
    switch platformString.lowercased() {
    case "ios":
        return .iOS
    case "macos":
        return .macOS
    case "tvos":
        return .tvOS
    case "watchos":
        return .watchOS
    default:
        fatalError("UNKNOWN PLATFORM FROM STRING \(platformString)")
    }
}

func stringFromPlatform(_ platform: Platform) -> String {
    switch platform {
    case .iOS:
        return "iOS"
    case .macOS:
        return "macOS"
    case .tvOS:
        return "tvOS"
    case .watchOS:
        return "watchOS"
    default:
        fatalError("UNKNOWN STRING FROM PLATFORM \(platform)")
    }
}

func getPlatformDependencies(platform: Platform, isSimulator: Bool = false) -> [TargetDependency] {
    var platformString = "\(platform)"
    var suffix = ""
    if isSimulator {
        suffix = "-simulator"
    }

    var tdDeps: [TargetDependency] = []

    for opensslInstallLib in [
        "libssl.a",
        "libcrypto.a",
    ] {
        tdDeps.append(
            .library(
                path: "\(tdIOSPath)/third_party/openssl/\(platformString + suffix)/lib/\(opensslInstallLib)",
                publicHeaders: "",
                swiftModuleMap: nil
            )
        )
    }

    for tdInstallLib in [
        "libtdactor.a",
        "libtdapi.a",
        "libtdnet.a",
        "libtdjson_private.a",
        "libtdjson_static.a",
        "libtddb.a",
        "libtdsqlite.a",
        "libtdclient.a",
        "libtdcore.a",
        "libtdutils.a",
    ] {
        tdDeps.append(
            .library(
                path: "\(tdIOSPath)/build/install-\(platformString + suffix)/lib/\(tdInstallLib)",
                publicHeaders: "",
                swiftModuleMap: nil
            )
        )
    }

    switch platform {
    case .iOS:
        if isSimulator {
            return tdDeps
        } else {
            return [
                .sdk(name: "libz.1.tbd"),
                .sdk(name: "libSystem.B.tbd"),
                .sdk(name: "libc++.1.tbd"),
                .sdk(name: "libc++abi.tbd"),
            ] + tdDeps
        }
    case .macOS:
        return [
            .sdk(name: "libz.1.tbd"),
            .sdk(name: "libSystem.B.tbd"),
            .sdk(name: "libc++.1.tbd"),
        ] + tdDeps
    default:
        return tdDeps
    }

    return []
}

func getTargets() -> [Target] {
    var targets: [Target] = []
    for rawPlatform in BuildPlatforms {
        var isSimulator = false
        var platform = rawPlatform
        var platformSuffix = ""
        if rawPlatform.hasSuffix(SimulatorSuffix) {
            platform = String(platform.dropLast(SimulatorSuffix.count))
            isSimulator = true
            platformSuffix = "-simulator"
        }
        let deps = getPlatformDependencies(platform: platformFromString(platform), isSimulator: isSimulator)

        targets.append(Target(
            name: rawPlatform,
            platform: platformFromString(platform),
            product: .framework,
            bundleId: "app.swiftgram.tdlibframework.\(rawPlatform)",
            infoPlist: "xcodeproj/Info.plist",
            headers: Headers(
                public: [
                    "\(tdPath)/td/telegram/td_json_client.h",
                    "\(tdPath)/td/telegram/td_log.h",
                    "xcodeproj/td.h",
                    // Additional Compiled header
                    "\(tdIOSPath)/build/install-\(rawPlatform)/include/td/telegram/tdjson_export.h",
                ]
            ),
            dependencies: deps,
            settings: Settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                    "PRODUCT_NAME": "TDLibFramework",
                ],
                configurations: [
                    .release(name: "Release", settings: ["SWIFT_OPTIMIZATION_LEVEL": "-O"]),
                ]
            )
        ))
    }

    return targets
}

let project = Project(
    name: "TDLibFramework",
    settings: Settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "12.0",
            "MACH_O_TYPE": "staticlib",
            "MODULEMAP_FILE": "$(SRCROOT)/xcodeproj/module.modulemap",
            "SWIFT_VERSION": "5.0",
            "MACOSX_DEPLOYMENT_TARGET": "10.12",
            "MARKETING_VERSION": .string(getVersion()),
        ]
    ),
    targets: getTargets()
)
