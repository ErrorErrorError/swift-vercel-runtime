//
//  Response.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//
//

import HTTPTypes

public struct Response: Sendable, Codable {
  public var statusCode: HTTPResponse.Status
  public var headers: HTTPResponse.PseudoHeaderFields?
  public var body: String?
  public var encoding: VercelEvent.Payload.Encoding?

  public init(
    statusCode: HTTPResponse.Status = .ok,
    headers: HTTPResponse.PseudoHeaderFields? = nil,
    body: String? = nil,
    encoding: VercelEvent.Payload.Encoding? = nil
  ) {
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
    self.encoding = encoding
  }
}

public extension Response {
  static let ok = Response(statusCode: .ok)
}
