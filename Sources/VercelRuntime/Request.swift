//
//  Request.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//
//

import AWSLambdaRuntime
import Foundation
import HTTPTypes

public struct Request: Sendable {
  public let context: LambdaContext
  public let method: HTTPRequest.Method
  public let headers: HTTPField
  public let path: String
  public let searchParams: [String: String]
  public let rawBody: Data?

  init(_ payload: VercelEvent.Payload, in context: LambdaContext) {
    self.context = context
    self.method = payload.method
    self.headers = payload.headers
    self.path = payload.path

    if let encoding = payload.encoding, let body = payload.body, encoding == .base64 {
      self.rawBody = Data(base64Encoded: body)
    } else {
      self.rawBody = payload.body?.data(using: .utf8)
    }

    self.searchParams = URLComponents(string: payload.path)?
      .queryItems?
      .reduce(into: [:]) { $0[$1.name] = $1.value } ?? [:]
  }
}
