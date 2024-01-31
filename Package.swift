// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "Refinery",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Refinery",
            targets: ["Refinery"]
        ),
        .library(
            name: "Examples",
            targets: ["Examples"]
        ),
    ],
    targets: [
        
        // Targets
        
        .target(
            name: "Refinery"
        ),
        .target(
            name: "Examples",
            dependencies: ["Refinery"]
        ),
        
        // Tests
        
        .testTarget(
            name: "RefineryTests",
            dependencies: ["Refinery"]
        ),
    ]
)
