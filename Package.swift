// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package.init(
  name: "swift-vercel-runtime",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .plugin(
      name: "VercelRouterTool",
      targets: ["VercelRouterTool"]
    ),
    .library(
      name: "VercelRuntime",
      targets: ["VercelRuntime"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha"),
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.4.0"),
  ],
  targets: [
    .plugin(
      name: "VercelRouterTool",
      capability: .command(
        intent: .custom(verb: "vercel-router-tool", description: "Tool used to generate routes for Vercel Runtime")
      )
    ),
    .target(
      name: "VercelRuntime",
      dependencies: [
        "VercelMacros",
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "HTTPTypes", package: "swift-http-types")
      ]
    ),
    .testTarget(
      name: "VercelRuntimeTests",
      dependencies: [
        "VercelRuntime"
      ]
    ),
    .macro(
      name: "VercelMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "VercelMacrosTests",
      dependencies: [
        "VercelMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing")
      ]
    )
  ]
)
