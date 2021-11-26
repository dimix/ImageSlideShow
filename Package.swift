// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageSlideShow",
	platforms: [
		.iOS(.v10)
	],
    products: [
        .library(
            name: "ImageSlideShow",
            targets: ["ImageSlideShow"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImageSlideShow",
            dependencies: [],
            resources: [.process("Storyboard")]
		)
    ]
)
