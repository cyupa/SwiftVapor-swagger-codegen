// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporTestInterface",
    products: [
        .library(name: "VaporTestInterface", targets: ["VaporTestInterface"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "VaporTestInterface", dependencies: ["Vapor"])
    ]
)