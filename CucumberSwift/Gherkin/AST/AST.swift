//
//  AST.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

class AST {
    static var standard:AST {
        return AST()
        .ruleFor(.feature, Rule.cleanAST
                                .then(.createNewNode)
                                .then(.appendTags))
        .ruleFor(.background, Rule.createNewNode
                                .then(.addToNearestParent))
        .ruleFor(.scenario, Rule.createNewNode
                                .then(.appendTags)
                                .then(.addToNearestParent))
        .ruleFor(.scenarioOutline, Rule.createNewNode
                                .then(.appendTags)
                                .then(.addToNearestParent))
        .ruleFor(.examples, Rule.traverseToAppropriateDepth)
        .ruleFor(.step, Rule.createNewNode
                                .then(.addToNearestParent))
    }
    
    private init(_ ruleLookup:[AST.Token?:Rule] = [:]) {
        self.ruleLookup = ruleLookup
    }
    
    func parse(_ tokens:[Lexer.Token]) -> [FeatureNode] {
        for token in tokens {
            if case Lexer.Token.tag(_) = token {
                tags.append(token)
            } else {
                if let t = AST.Token(token) {
                    ruleLookup[t]?.execute(t, self)
                }
                currentNode?.tokens.append(token)
            }
        }
        return featureNodes
    }
    var featureNodes:[FeatureNode] = []
    var ruleLookup:[AST.Token?:Rule] = [:]
    var nodeLookup:[UInt:Node] = [:]
    var tags = [Lexer.Token]()

    var currentNode:Node?

    func ruleFor(_ token:AST.Token, _ rule:Rule) -> AST {
        var ruleLookup = self.ruleLookup
        ruleLookup[token] = rule
        return AST(ruleLookup)
    }
}
