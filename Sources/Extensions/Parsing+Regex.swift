//
//  Parsing+Regex.swift
//  
//
//  Created by Alexander Weiß on 28.12.20.
//

import Foundation
import Parsing

internal struct PrefixUpToRegex<Input>: Parser {
    
    public let regex: String
    
    @inlinable
    public init(_ regex: String) {
        self.regex = regex
    }
    
    @inlinable
    @inline(__always)
    func parse(_ input: inout Substring) -> Substring? {
        let strInput = String(input)
        let regex = try! NSRegularExpression(pattern: self.regex, options: NSRegularExpression.Options.caseInsensitive)
        let regexMatches = regex.matches(in: strInput, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        guard let regexMatch = regexMatches.first,
              let range = Range(regexMatch.range(at: 1), in: input)
        else {
            return nil
        }
        
        let endIndex = range.lowerBound
        
        let match = input[..<endIndex]
        
        input = input[endIndex...]
        
        return match
    }
}
