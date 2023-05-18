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
            checksum: "62caaff1a7926b8a3d3670bb7c5548ccc581fb7a89426a027c187d48f2d765cd"),
    ]
)
