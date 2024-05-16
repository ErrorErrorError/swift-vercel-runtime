//
//  VercelRuntime.swift
//
//
//  Created by ErrorErrorError on 5/15/24.
//
//

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
