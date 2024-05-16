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
  func routePath(base path: String) -> String {
    String(filePath.dropLast(6))
      .replacingOccurrences(of: path, with: "")
  }
}
