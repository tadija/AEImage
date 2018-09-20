// swift-tools-version:4.2

/**
 *  https://github.com/tadija/AEImage
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

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
