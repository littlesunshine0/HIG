// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HIG",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HIGPackage",
            targets: ["HIGPackage"]
        ),
        .executable(
            name: "hig-cli",
            targets: ["HIGCLI"]
        )
    ],
    targets: [
        .target(
            name: "HIGPackage",
            path: "Sources/HIGPackage"
        ),
        .executableTarget(
            name: "HIGCLI",
            dependencies: ["HIGPackage"],
            path: "Sources/HIGCLI",
            exclude: ["README.md"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "HIGPackageTests",
            dependencies: ["HIGPackage"],
            path: "Tests/HIGPackageTests",
            resources: [
                .process("Fixtures")
            ],
            swiftSettings: [
                .unsafeFlags(["-disable-test-discovery"], .when(platforms: [.linux]))
            ]
        )
    ]
)
