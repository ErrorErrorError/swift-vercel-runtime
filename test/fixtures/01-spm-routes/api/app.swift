import VercelRuntime

@main
@Routable
struct App: Routable {
  var routes: [VercelRuntime.Route.Type] = [
    PostsIdRoute.self,
    PostsRoute.self,
    IdRoute.self,
    CatchAllIdRoute.self,
    OptionalCatchAllPostIDRoute.self
  ]
}