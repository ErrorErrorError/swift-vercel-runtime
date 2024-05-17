import VercelMacros
import VercelRuntime

@Route
struct OptionalCatchAllPostIDRoute {
  func resolve(_ request: Request) async throws -> Response {
    .ok
  }
}