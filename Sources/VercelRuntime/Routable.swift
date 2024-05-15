#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import AWSLambdaRuntime

public protocol Routable {
  init()
  
  var routes: [Route.Type] { get }
  var filePath: String { get }
}

extension Routable {
  public static func main() throws {
    // setenv("AWS_LAMBDA_RUNTIME_API", "127.0.0.1:0", 0)
    VercelRuntime<Self>.main()
  }
  
  var basePath: String {
    if let indexRange = filePath.lastIndex(of: "/") ?? filePath.lastIndex(of: "\\") {
      return String(filePath[..<indexRange])
    } else {
      return filePath
    }
  }
}
