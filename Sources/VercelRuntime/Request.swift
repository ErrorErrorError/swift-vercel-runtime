import AWSLambdaRuntime
import HTTPTypes
import Foundation

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
    
    if let encoding = payload.encoding, let body = payload.body, encoding == "base64" {
        rawBody = Data(base64Encoded: body)
    } else {
        rawBody = payload.body?.data(using: .utf8)
    }
    
    self.searchParams = URLComponents(string: payload.path)?
        .queryItems?
        .reduce(into: [:]) { $0[$1.name] = $1.value } ?? [:]
  }
}
