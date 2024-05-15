import VercelRuntime

struct App: Routable {
  var routes: [VercelRuntime.Route.Type] = [
    RootRoute.self
  ]
}

// Only if you are not using @main
try App.main()
