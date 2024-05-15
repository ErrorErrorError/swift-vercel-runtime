import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
  var providingMacros: [Macro.Type] = [
    RouteMacro.self,
    RoutableMacro.self,
  ]
}
