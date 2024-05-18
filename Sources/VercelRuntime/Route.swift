//
//  Route.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//
//

public protocol Route {
  init()

  var filePath: String { get }
  func resolve(_ request: Request) async throws -> Response
}

extension Route {
  func callAsFunction(base path: String) -> String {
    String(filePath.dropLast(6).trimmingPrefix(path))
  }
  
  func callAsFunction(_ request: Request) async throws -> Response {
    try await resolve(request)
  }
}
