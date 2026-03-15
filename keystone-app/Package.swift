// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Keystone",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Keystone", targets: ["Keystone"])
    ],
    targets: [
        .executableTarget(
            name: "Keystone",
            path: "Keystone/Source"
        )
    ]
)
