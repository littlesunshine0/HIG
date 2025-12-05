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
        )
    ],
    targets: [
        .target(
            name: "HIGPackage",
            path: "Sources/HIGPackage"
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
