//
//  root.swift
//
//
//  Created by ErrorErrorError on 5/14/24.
//  
//

import VercelMacros
import VercelRuntime

@Route
struct RootRoute {
  func resolve(_ request: Request) async throws -> Response {
    .init()
  }
}
