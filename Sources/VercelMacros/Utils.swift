//
//  Utils.swift
//
//
//  Created by ErrorErrorError on 5/13/24.
//
//

import SwiftSyntax
import SwiftSyntaxMacros

extension MemberBlockItemListSyntax {
  func contains(initializer params: FunctionParameterListSyntax = []) -> Bool {
    self.contains { syntax in
      guard let initializer = syntax.decl.as(InitializerDeclSyntax.self) else {
        return false
      }
      return initializer.signature.parameterClause.parameters == params
    }
  }
  
  func contains(property name: String) -> Bool {
    self.contains { syntax in
      guard let variable = syntax.decl.as(VariableDeclSyntax.self) else {
        return false
      }
      
      let identifier = variable.bindings.compactMap { bind in
        bind.pattern.as(IdentifierPatternSyntax.self)
      }
      .first

      guard let identifier else {
        return false
      }

      return identifier.identifier.trimmedDescription == name
    }
  }
}
