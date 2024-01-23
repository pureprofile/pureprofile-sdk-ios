// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureprofileSDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PureprofileSDK",
            targets: ["PureprofileSDK"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "PureprofileSDK",
            url: "https://devtools.pureprofile.com/surveys/ios/latest/PureprofileSDK.zip",
            checksum: "404142f2126a24e462af3d5fe6700fb1de692ff5fd6c4ddb744e276ed213e64c"),
    ]
)
