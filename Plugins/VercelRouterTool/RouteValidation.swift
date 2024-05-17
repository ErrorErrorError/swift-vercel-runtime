//
//  RouteValidation.swift
//
//
//  Created by ErrorErrorError on 5/13/24.
//
//

public struct RouteMetadata: Equatable, Sendable, Encodable {
  static let excludeFromRoutes = ["main.swift", "app.swift", "Package.swift"]

  public let path: String
  public let segments: [String]?
  public let routeType: RouteKind

  public init?(path: String) {
    let lowercased = path.lowercased()
    guard lowercased.hasSuffix(".swift"), 
          Self.excludeFromRoutes.allSatisfy({ !lowercased.hasSuffix($0) }) else {
      return nil
    }

    let path = path.removeSuffix(".swift")
    self.routeType = RouteKind(path: path)
    self.path = path
    self.segments = path.split(whereSeparator: { $0 == "/" }).map(String.init)
  }
}

extension RouteMetadata {
  public enum RouteKind: Int, Equatable, Sendable, Encodable {
    // Static Route - /api/user
    case `static`
    
    // Dynamic Route - /api/[id]
    case dynamic
    
    // Catch-all Route - /api/[...slug]
    case catchAll
    
    // Optional catch-all Route - /api/[[...slug]]
    case optionalCatchAll
    
    init(path: String) {
      let dynamicRouteRegex = #/\[[^/\.]+\]/#
      let dynamicCatchAllRegex = #/\[\.{3}\S+\]/#
      let dynamicOptionalCatchAllRegex = #/\[{2}\.{3}\S+\]{2}/#
      
      if dynamicRouteRegex.isMatch(in: path) {
        if dynamicOptionalCatchAllRegex.isMatch(in: path) {
          self = .optionalCatchAll
        } else if dynamicCatchAllRegex.isMatch(in: path) {
          self = .catchAll
        } else {
          self = .dynamic
        }
      } else if dynamicOptionalCatchAllRegex.isMatch(in: path) {
        self = .optionalCatchAll
      } else if dynamicCatchAllRegex.isMatch(in: path) {
        self = .catchAll
      } else {
        self = .static
      }
    }
  }
}

extension RouteMetadata: CustomStringConvertible {
  public var description: String {
    """
    \(Self.self)(
      path: \(path)
      kind: \(routeType)
      segments: \(segments ?? [])
    )
    """
  }
}

extension String {
  func appendPrefix(_ string: String) -> String {
    if self.hasPrefix(string) {
      self
    } else {
      string + self
    }
  }
  
  func appendSuffix(_ string: String) -> String {
    if self.hasSuffix(string) {
      self
    } else {
      self + string
    }
  }
  
  func removePrefix(_ string: String) -> String {
    if self.hasPrefix(string) {
      String(self.dropFirst(string.count))
    } else {
      self
    }
  }
  
  func removeSuffix(_ string: String) -> String {
    if self.hasSuffix(string) {
      String(self.dropLast(string.count))
    } else {
      self
    }
  }
}

fileprivate extension Regex {
  func isMatch(in string: String) -> Bool {
    (try? self.firstMatch(in: string)) != nil
  }
}
