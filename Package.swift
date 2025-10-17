// swift-tools-version: 6.1

import PackageDescription

let package = Package(name: "Application", products: [
    .library(name: "Application", type: .dynamic, targets: ["Application"]),
], dependencies: [
    .package(url: "https://github.com/purpln/android-assets.git", branch: "main"),
    .package(url: "https://github.com/purpln/android-log.git", branch: "main"),
    .package(url: "https://github.com/purpln/java.git", branch: "main"),
    .package(url: "https://github.com/purpln/native-activity.git", branch: "main"),
], targets: [
    .target(name: "Application", dependencies: [
        .product(name: "AndroidAssets", package: "android-assets"),
        .product(name: "AndroidLog", package: "android-log"),
        .product(name: "Java", package: "java"),
        "Instance",
        "TranslationLayer",
    ]),
    .target(name: "Instance", dependencies: [
        .product(name: "AndroidLog", package: "android-log"),
        .product(name: "NativeActivity", package: "native-activity"),
    ]),
    .target(name: "TranslationLayer", dependencies: [
        .product(name: "Java", package: "java"),
    ]),
])
