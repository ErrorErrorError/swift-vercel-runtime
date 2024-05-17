import VercelMacros
import VercelRuntime

@Route
struct PostsRoute {
  func resolve(_ request: Request) async throws -> Response {
    .ok
  }
}