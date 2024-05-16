//
//  RouteMacro.swift
//
//
//  Created by ErrorErrorError on 5/13/24.
//
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

private enum ExtensionsMacroError: Swift.Error {
  case failedToCast
  case requiresClassOrStruct
}

enum RoutableMacro {
  static let package = "VercelRuntime"
  static let routableName = "Routable"
  static let qualifiedRoutable = "\(package).\(routableName)"
}

extension RoutableMacro: ExtensionMacro {
  static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    if let inheritanceClause = declaration.inheritanceClause,
       inheritanceClause.inheritedTypes.contains(
         where: {
           [routableName, qualifiedRoutable].contains($0.type.trimmedDescription)
         }
       )
    {
      return []
    }

    let routableExtension: DeclSyntax = """
    extension \(type.trimmed): \(raw: qualifiedRoutable) {}
    """

    guard let routable = routableExtension.as(ExtensionDeclSyntax.self) else {
      throw ExtensionsMacroError.failedToCast
    }

    return [routable]
  }
}

extension RoutableMacro: MemberMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self) else {
      throw ExtensionsMacroError.requiresClassOrStruct
    }

    let modifiers = declaration.as(ClassDeclSyntax.self)?.modifiers ?? declaration.as(StructDeclSyntax.self)?.modifiers ?? []
    let hasPublic = modifiers.contains { $0.name.tokenKind == .keyword(.public) }

    var syntax = [DeclSyntax]()

    if !declaration.memberBlock.members.contains(property: "filePath") {
      syntax.append("\(raw: hasPublic ? "public " : "")let filePath = #filePath")
    }

    if !declaration.memberBlock.members.contains(initializer: []) {
      syntax.append("\(raw: hasPublic ? "public " : "")init() {}")
    }

    return syntax
  }
}
