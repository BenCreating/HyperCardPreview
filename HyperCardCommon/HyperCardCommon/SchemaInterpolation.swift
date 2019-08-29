//
//  SchemaInterpolation.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//



extension Schema: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {
    
    public typealias StringInterpolation = SchemaInterpolation
    public typealias StringLiteralType = String
    
    public convenience init(stringLiteral: String) {
        
        self.init()
        
        let string = HString(stringLiteral: stringLiteral)
        let tokens = TokenSequence(string)
        
        for token in tokens {
            
            self.appendTokenKind(filterBy: { (t: Token) -> Bool in
                t == token
            }, minCount: 1, maxCount: 1, isConstant: true)
        }
    }
    
    public convenience init(stringInterpolation: SchemaInterpolation) {
        
        self.init(schemaLiteral: stringInterpolation.schema)
        
        for after in stringInterpolation.afters {
            
            after.apply(to: self)
        }
    }
    
}

public struct SchemaInterpolation: StringInterpolationProtocol {
    
    public typealias StringLiteralType = String
    
    let schema = Schema<Void>()
    
    var afters: [After] = []
    
    class After {
        
        func apply<T>(to schema: Schema<T>) {
            fatalError()
        }
    }
    
    private class ComputeBranchAfter<T>: After {
        
        override func apply<U>(to schema: Schema<U>) {
            
            guard T.self == U.self else {
                fatalError()
            }
            
            schema.computeBranchBy(for: schema, { (value: U) -> U in
                return value
            })
        }
    }
    
    public init(literalCapacity: Int, interpolationCount: Int) {
    }
    
    public func appendLiteral(_ literal: String) {
        
        let string = HString(converting: literal)!
        let tokens = TokenSequence(string)
        
        for token in tokens {
            
            self.schema.appendTokenKind(filterBy: { (t: Token) -> Bool in
                t == token
            }, minCount: 1, maxCount: 1, isConstant: true)
        }
    }
    
    public func appendInterpolation<U>(_ schema: Schema<U>) {
        
        self.schema.appendSchema(schema, minCount: 1, maxCount: 1)
    }
    
    public func appendInterpolation<U>(multiple schema: Schema<U>, atLeast minCount: Int = 0, atMost maxCount: Int? = nil) {
        
        self.schema.appendSchema(schema, minCount: minCount, maxCount: maxCount)
    }
    
    public func appendInterpolation<U>(maybe schema: Schema<U>) {
        
        self.schema.appendSchema(schema, minCount: 0, maxCount: 1)
    }
    
    public func appendInterpolation<U>(or schema: Schema<U>) {
        
        self.schema.appendBranchedSchema(schema)
    }
    
    public func appendInterpolation(_ token: Token) {
        
        self.schema.appendTokenKind(filterBy: { $0 == token }, minCount: 1, maxCount: 1, isConstant: true)
    }
}




