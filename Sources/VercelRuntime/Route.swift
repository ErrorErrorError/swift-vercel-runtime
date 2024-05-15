public protocol Route {
  init()
  
  var filePath: String { get }
  func resolve(_ request: Request) async throws -> Response
}

extension Route {
  var routePath: String { String(filePath.dropLast(6)) }
}
