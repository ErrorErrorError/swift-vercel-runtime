// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package.init(
  name: "VercelRuntime",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "VercelRuntime",
      targets: ["VercelRuntime"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "VercelRuntime",
      dependencies: []
    )
    // .testTarget(
    //   name: "VercelRuntimeTests",
    //   dependencies: ["VercelRuntime"],
    //   path: "Tests/VercelRuntimeTests/"
    // ),
  ]
)
