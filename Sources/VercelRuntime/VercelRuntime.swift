import AWSLambdaRuntime
import Foundation
import HTTPTypes
import NIOCore

struct VercelRuntime<T: Routable>: @unchecked Sendable {
  typealias Event = VercelEvent
  typealias Output = Response
  
  let routable: T
  
  init(type: T.Type = T.self) {
    self.routable = type.init()
  }
}

fileprivate extension Routable {
  func resolveRoute(path: String) throws -> Route {
    let basePath = self.basePath
    let route = self.routes.first { routeType in
      let route = routeType.init()
      let routePath = route.routePath
      let clearedPath = routePath.replacingOccurrences(of: basePath, with: "")
      return path == clearedPath
    }
    
    guard let route else {
      fatalError()
    }
    
    return route.init()
  }
}

extension VercelRuntime: EventLoopLambdaHandler {
  static func makeHandler(context: LambdaInitializationContext) -> EventLoopFuture<Self> {
    context.eventLoop.makeFutureWithTask {
      .init()
    }
  }
  
  func handle(_ event: VercelEvent, context: LambdaContext) -> NIOCore.EventLoopFuture<Response> {
    context.eventLoop.makeFutureWithTask {
      let data = Data(event.body.utf8)
      let payload = try JSONDecoder().decode(VercelEvent.Payload.self, from: data)
      let request = Request(payload, in: context)
      let route = try routable.resolveRoute(path: payload.path)
      return try await route.resolve(request)
    }
  }
}

struct VercelEvent: Codable, Sendable {
  public struct Payload: Sendable, Decodable {
    public let method: HTTPRequest.Method
    public let headers: HTTPField
    public let path: String
    public let body: String?
    public let encoding: String?
  }
  
  public let body: String
}

extension HTTPRequest.Method: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self = .init(rawValue: try container.decode(String.self)) ?? .get
  }
}
