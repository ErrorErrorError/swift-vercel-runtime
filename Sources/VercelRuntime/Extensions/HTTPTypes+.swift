//
//  File.swift
//  
//
//  Created by ErrorErrorError on 5/15/24.
//  
//

import HTTPTypes

extension HTTPRequest.Method: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self = .init(rawValue: try container.decode(String.self)) ?? .get
  }
}

extension HTTPResponse.Status: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.init(code: container.decode(Int.self))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.code)
  }
}
