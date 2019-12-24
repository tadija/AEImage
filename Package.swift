// swift-tools-version:5.1

/**
 *  https://github.com/tadija/AEImage
 *  Copyright © 2016-2019 Marko Tadić
 *  Licensed under the MIT license
 */

import PackageDescription

let package = Package(
    name: "AEImage",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "AEImage",
            targets: ["AEImage"]
        )
    ],
    targets: [
        .target(
            name: "AEImage"
        )
    ]
)
