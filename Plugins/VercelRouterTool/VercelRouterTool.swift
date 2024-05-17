import Foundation
import PackagePlugin

@main
struct VercelRouterTool: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let mainExecutable = context.package.products(ofType: ExecutableProduct.self)
      .first { executable in
        executable.targets.first { target in
          target.dependencies.contains { dependency in
            switch dependency {
            case let .product(product):
              product.name.hasPrefix("VercelRuntime")
            default:
              false
            }
          }
        } != nil
      }
    
    guard let mainExecutable else {
      print("Could not find main executable with 'VercelRuntime' as a dependency.")
      return
    }
    
    let baseDirectory = context.package.directory.string
    let mainDir = mainExecutable.mainTarget.directory.string
    let relativeDir = mainDir.replacingOccurrences(of: baseDirectory, with: "")

    print("Base Directory", baseDirectory)
    print("Main Executable Directory", mainDir)
    print("Relative Dir", relativeDir)
    
    let allFiles = mainExecutable.mainTarget.sourceModule?.sourceFiles(withSuffix: "swift").map { $0 } ?? []
    var routers = [RouteMetadata]()

    for file in allFiles where file.type == .source {
      let path = file.path.string.removePrefix(baseDirectory)
      if let route = RouteMetadata(path: path) {
        routers.append(route)
      }
    }
    
    print("All Routes Available: ", routers)
    
    let json = try JSONEncoder().encode(routers)
    let filePath = context.package.directory.appending("routes.json")
    try json.write(to: .init(filePath: filePath.string))
    
    print("Successfully outputed available routes.")
  }
}
