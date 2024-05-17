import VercelMacros
import VercelRuntime

@Route
struct IdRoute {
  func resolve(_ request: Request) async throws -> Response {
    .ok
  }
}