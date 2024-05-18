import Foundation
import PackagePlugin

@main
struct VercelRouterTool: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    print("\(Self.self) - version: \(context.package.toolsVersion.versionString)")
    let mainExecutable = context.package.products(ofType: ExecutableProduct.self)
      .first { product in
        product.targets.contains { target in
          target.dependencies.contains { dependency in
            switch dependency {
            case let .product(product):
              product.name == "VercelRuntime"
            default:
              false
            }
          }
        }
      }
    
    guard let mainExecutable else {
      print("Could not find a main executable with 'VercelRuntime' as a dependency.")
      exit(1)
    }
    
    let baseDirectory = context.package.directory.string
    let allFiles = mainExecutable.mainTarget.sourceModule?.sourceFiles(withSuffix: "swift").map { $0 } ?? []
    
    var routesOutput = RoutesOutput(executableName: mainExecutable.name)
    
    for file in allFiles where file.type == .source {
      let path = file.path.string.removePrefix(baseDirectory)
      if let route = RouteMetadata(path: path) {
        routesOutput.routes.append(route)
      }
    }
    
    let json = try JSONEncoder().encode(routesOutput)
    let filePath = context.pluginWorkDirectory.appending("routes.json")
    try json.write(to: .init(filePath: filePath.string))
    
    print("Successfully wrote available routes to:", filePath.string)
  }
}

extension ToolsVersion {
  var versionString: String {
    "\(major).\(minor).\(patch)"
  }
}
