// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "Refinery",
    platforms: [.iOS("16.4")],
    products: [
        .library(
            name: "Refinery",
            targets: ["Refinery"]
        )
    ],
    targets: [
        
        // Targets
        
        .target(
            name: "Refinery"
        ),
        
        // Tests
        
        .testTarget(
            name: "RefineryTests",
            dependencies: ["Refinery"]
        ),
    ]
)
