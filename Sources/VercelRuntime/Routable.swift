//
//  Routable.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//
//

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import AWSLambdaRuntime

public protocol Routable {
  init()

  var routes: [Route.Type] { get }
  var filePath: String { get }
}

public extension Routable {
  static func main() throws {
    // setenv("AWS_LAMBDA_RUNTIME_API", "127.0.0.1:0", 0)
    VercelRuntime<Self>.main()
  }
}

extension Routable {
  var basePath: String {
    if let indexRange = filePath.lastIndex(of: "/") ?? filePath.lastIndex(of: "\\") {
      String(filePath[..<indexRange])
    } else {
      filePath
    }
  }

  func resolveRoute(path expectedPath: String) throws -> Route {
    let basePath = self.basePath

    for routeType in self.routes {
      let route = routeType.init()
      let path = route.routePath(base: basePath)
      if expectedPath == path {
        return route
      }
    }

    fatalError("Route not found. Implement fallback")
  }
}
