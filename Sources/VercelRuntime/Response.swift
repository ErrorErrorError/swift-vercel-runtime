import HTTPTypes

public struct Response: Sendable, Codable {
  public var statusCode: HTTPResponse.Status
  public var headers: HTTPResponse.PseudoHeaderFields?
  public var body: String?
  public var encoding: Encoding?
  
  public init(
    statusCode: HTTPResponse.Status = .ok,
    headers: HTTPResponse.PseudoHeaderFields? = nil,
    body: String? = nil,
    encoding: Encoding? = nil
  ) {
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
    self.encoding = encoding
  }
  
  public enum Encoding: String, Sendable, Codable {
    case base64
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
