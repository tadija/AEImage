// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AEImage",
    products: [
        .library(name: "AEImage", targets: ["AEImage"])
    ],
    targets: [
        .target(
            name: "AEImage"
        )
    ]
)
