// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "Application", products: [
    .library(name: "Application", type: .dynamic, targets: ["Application"]),
], dependencies: [
    .package(url: "https://github.com/purpln/android-assets.git", branch: "main"),
    .package(url: "https://github.com/purpln/android-log.git", branch: "main"),
    .package(url: "https://github.com/purpln/native-activity.git", branch: "main"),
], targets: [
    .target(name: "Application", dependencies: [
        .product(name: "AndroidAssets", package: "android-assets"),
        .product(name: "AndroidLog", package: "android-log"),
        .product(name: "NativeActivity", package: "native-activity"),
    ]),
])
