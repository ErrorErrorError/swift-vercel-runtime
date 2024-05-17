import VercelMacros
import VercelRuntime

@Route
struct PostsIdRoute {
  func resolve(_ request: Request) async throws -> Response {
    .ok
  }
}