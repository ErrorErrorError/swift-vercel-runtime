//
//  Macros.swift
//  
//
//  Created by ErrorErrorError on 5/12/24.
//  
//

import VercelMacros

@attached(extension, conformances: Route)
@attached(member, names: named(filePath), named(init))
public macro Route() = #externalMacro(module: "VercelMacros", type: "RouteMacro")

@attached(extension, conformances: Routable)
@attached(member, names: named(filePath), named(init))
public macro Routable() = #externalMacro(module: "VercelMacros", type: "RoutableMacro")
