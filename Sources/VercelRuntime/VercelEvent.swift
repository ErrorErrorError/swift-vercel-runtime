//
//  VercelEvent.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//  
//

import HTTPTypes

public struct VercelEvent: Codable, Sendable {
  public struct Payload: Sendable, Decodable {
    public enum Encoding: String, Sendable, Codable {
      case base64
    }
    
    public let method: HTTPRequest.Method
    public let headers: HTTPField
    public let path: String
    public let body: String?
    public let encoding: Encoding?
  }
  
  public let body: String
}
