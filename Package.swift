// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "BlackBoxFirebaseCrashlytics"
let libraryName = packageName
let targetName = libraryName
let testTargetName = targetName + "Tests"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v15), .macCatalyst(.v15), .macOS(.v10_15), .tvOS(.v15), .watchOS(.v7)], // should stay synced with https://github.com/firebase/firebase-ios-sdk/blob/main/Package.swift,
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: libraryName,
            targets: [targetName]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/dodobrands/BlackBox.git",
            .upToNextMajor(from: "4.0.1")
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "12.0.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: targetName,
            dependencies: [
                "BlackBox",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: testTargetName,
            dependencies: [
                .targetItem(name: targetName, condition: nil),
                "BlackBox"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
