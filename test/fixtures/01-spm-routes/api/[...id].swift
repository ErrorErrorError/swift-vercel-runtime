import VercelMacros
import VercelRuntime

@Route
struct CatchAllIdRoute {
  func resolve(_ request: Request) async throws -> Response {
    .ok
  }
}