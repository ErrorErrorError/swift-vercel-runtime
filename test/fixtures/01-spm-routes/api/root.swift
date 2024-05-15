import VercelMacros
import VercelRuntime

@Route
struct RootRoute {
  func resolve(_ request: VercelRuntime.Request) async throws -> VercelRuntime.Response {
    .init()
  }
}
