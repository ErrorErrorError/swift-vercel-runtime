//
//  VercelRuntimeTests.swift
//  
//
//  Created by ErrorErrorError on 5/14/24.
//  
//

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import XCTest
@testable import VercelRuntime

final class VercelRuntimeTests: XCTestCase {
  func testFindingRoutes() throws {
    setenv("LOCAL_LAMBDA_SERVER_ENABLED", "true", 0)
    try App.main()
  }
}
