//
//  VercelMacrosTests.swift
//  
//
//  Created by ErrorErrorError on 5/12/24.
//  
//

import XCTest
import MacroTesting
@testable import VercelMacros

final class VercelMacrosTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      isRecording: true,
      macros: [
        "Route": RouteMacro.self
      ]
    ) {
      super.invokeTest()
    }
  }
  
  func testRouteMacro() throws {
    assertMacro {
      """
      @Route
      public struct RootRoute {
        func resolve(_ request: VercelRuntime.Request) async throws -> VercelRuntime.Respond {
          fatalError()
        }
      }
      """
    } diagnostics: {
      """

      """
    } expansion: {
      """
      public struct RootRoute {
        func resolve(_ request: VercelRuntime.Request) async throws -> VercelRuntime.Respond {
          fatalError()
        }

        public let filePath = #filePath
      }

      extension RootRoute: VercelRuntime.Route {
      }
      """
    }
  }
}
