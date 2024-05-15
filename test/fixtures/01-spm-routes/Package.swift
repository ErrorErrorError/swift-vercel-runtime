// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "App",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(
      name: "App", 
      targets: ["App"]
    )
  ],
  dependencies: [
    .package(name: "VercelRuntime", path: "../../../")
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "VercelRuntime", package: "VercelRuntime")
      ],
      path: "api"
    )
  ]
)
