import ProjectDescription

import Foundation

enum ShellError: Error {
    case generic(statusCode: Int32, message: String, output: String)
}

func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    while (task.isRunning) {
        continue
    }
    if task.terminationStatus != 0 {
        throw ShellError.generic(statusCode: task.terminationStatus, message: "Error running \(command)", output: output)
    }

    return output
}

let rootPath = ".."
let tdPath = "\(rootPath)/td"
let tdIOSPath = "\(tdPath)/example/ios"

func getTDLibCommitSha() -> String {
    return try! shell("cd \(tdPath) && git rev-parse --short=8 HEAD").trimmingCharacters(in: .whitespacesAndNewlines)
}

func getTDLibVersion() -> String {
    return try! shell("python3 \(rootPath)/scripts/extract_td_version.py \(tdPath)/CMakeLists.txt").trimmingCharacters(in: .whitespacesAndNewlines)
}

func getFullVersion() -> String {
    let td_git_tag = getTDLibCommitSha()
    var version = getTDLibVersion()

    if version.isEmpty {
        version = td_git_tag
    } else {
        version = "\(version)-\(td_git_tag)"
    }

    print("TD version: \(version)")
    return version
}

func getMinimumOSVersion(_ platform: String) -> String {
    return try! shell("python3 \(rootPath)/scripts/extract_os_version.py \(platform)")
}

let SimulatorSuffix = "-simulator"



func getBuildPlatforms() -> [String] {
return Environment.platform.getString(default: "iOS,iOS-simulator,macOS,watchOS,watchOS-simulator,tvOS,tvOS-simulator,visionOS,visionOS-simulator").components(separatedBy: ",")
}

let BuildPlatforms = getBuildPlatforms()
print("\nGenerating project for platforms \(BuildPlatforms)")

func destinationFromPlatformString(_ destinationString: String) -> Destinations {
    switch destinationString.lowercased() {
    case "ios":
        return .iOS
    case "macos":
        return .macOS
    case "tvos":
        return .tvOS
    case "watchos":
        return .watchOS
    case "visionos":
        return .visionOS
    default:
        fatalError("UNKNOWN DESTINATION FROM STRING \(destinationString)")
    }
}

func stringFromDestination(_ destination: Destinations) -> String {
    switch destination {
    case .iOS:
        return "iOS"
    case .macOS:
        return "macOS"
    case .tvOS:
        return "tvOS"
    case .watchOS:
        return "watchOS"
    case .visionOS:
        return "visionOS"
    default:
        fatalError("UNKNOWN STRING FROM DESTINATION \(destination)")
    }
}

func getPlatformDependencies(destination: Destinations, isSimulator: Bool = false) -> [TargetDependency] {
    var platformString = stringFromDestination(destination)
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
        "libtdmtproto.a",
    ] {
        tdDeps.append(
            .library(
                path: "\(tdIOSPath)/build/install-\(platformString + suffix)/lib/\(tdInstallLib)",
                publicHeaders: "",
                swiftModuleMap: nil
            )
        )
    }
    
    switch destination {
    case .iOS:
        if isSimulator {
            return tdDeps
        } else {
            return [
                .sdk(name: "libz.tbd", type: .library),
                .sdk(name: "libc++.tbd", type: .library),
            ] + tdDeps
        }
    case .macOS:
        return [
            .sdk(name: "libz.tbd", type: .library),
            .sdk(name: "libc++.tbd", type: .library),
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
        if rawPlatform.hasSuffix(SimulatorSuffix) {
            platform = String(platform.dropLast(SimulatorSuffix.count))
            isSimulator = true
        }
        let deps = getPlatformDependencies(destination: destinationFromPlatformString(platform), isSimulator: isSimulator)
        targets.append(
            .target(
                name: rawPlatform,
                destinations: destinationFromPlatformString(platform),
                product: .framework,
                bundleId: "app.swiftgram.tdlibframework.\(rawPlatform)",
                infoPlist: "xcodeproj/Info.plist",
                headers: .headers(public: .list([
                    "\(tdPath)/td/telegram/td_json_client.h",
                    "\(tdPath)/td/telegram/td_log.h",
                    "xcodeproj/td.h",
                    // Additional Compiled header
                    "\(tdIOSPath)/build/install-\(rawPlatform)/include/td/telegram/tdjson_export.h",
                ])),
                dependencies: deps,
                settings: .settings(
                    base: [
                        "PRODUCT_NAME": "TDLibFramework",
                        "SWIFT_VERSION": "5.0" //stub
                    ],
                    configurations: [
                        .release(name: .release, settings: ["SWIFT_OPTIMIZATION_LEVEL": "-O"])
                    ]
                )
            )
        )
    }
    
    return targets
}

let project = Project(
    name: "TDLibFramework",
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": .string(getMinimumOSVersion("iOS")),
            "MACOSX_DEPLOYMENT_TARGET": .string(getMinimumOSVersion("macOS")),
            "WATCHOS_DEPLOYMENT_TARGET": .string(getMinimumOSVersion("watchOS")),
            "TVOS_DEPLOYMENT_TARGET": .string(getMinimumOSVersion("tvOS")),
            "XROS_DEPLOYMENT_TARGET": .string(getMinimumOSVersion("visionOS")),
            "MACH_O_TYPE": "staticlib",
            "MODULEMAP_FILE": "$(SRCROOT)/xcodeproj/module.modulemap",
            "SWIFT_VERSION": "5.0", // stub
            "MARKETING_VERSION": .string(getTDLibVersion()),
            "TDLIB_VERSION": .string(getFullVersion())
        ]
    ),
    targets: getTargets()
)
