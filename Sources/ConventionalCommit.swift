//
//  ConventionalCommit.swift
//  
//
//  Created by Alexander Weiß on 17.10.20.
//

import Parsing

// MARK: - Conventional Commit

/// Type safe representation of a Conventional Commit
public struct ConventionalCommit {
   
    /// Internal encapsulations
    private let _header: Header
    private let _body: String?
    private let _footers: [Footer]
    
    /// The type of commit
    public var type: String {
        return _header.type
    }
    
    /// Optional scope of the commit
    public var scope: String? {
        return _header.scope
    }
    
    /// Single line description of the contents of the commit
    public var description: String {
        return _header.description
    }
    
    /// Flag for a breaking change commit
    public var isBreaking: Bool {
        return _header.breaking || _footers.map { $0.isBreaking }.contains(true)
    }
    
    /// An optional longer, possibly multiline/multiparagraph, body commit message
    public var body: String? {
        return _body
    }
    
    /// List of footers
    public var footers: [Footer] {
        return _footers
    }
}

// MARK: Parser
extension ConventionalCommit {
    
    /// A parser capable of parsing a `ConventionalCommit` of a `Substring`
    private static let parser: AnyParser<Substring, ConventionalCommit> = {
        
        // When the body is empty the body will be nil
        func convertSubstringToBody(substring: Substring?) -> String? {
            if substring == nil {
                return nil
            } else {
                let str = String(substring!)
                
                if (str.isEmpty) {
                    return nil
                }
                
                return str
            }
        }
        
        let headerParser = ConventionalCommit.Header.parser
        let singleFooterParser = ConventionalCommit.Footer.parser
        
        //TODO: maybe try to use something else to find the
        //beginning of the footers?
  
        // These regexes try to find the beginning of the footers section:
        // 1. BREAKING CHANGE token after a new line
        // 2. BREAKING CHANGE token without a new line
        // 3. BREAKING-CHANGE token after a new line
        // 4. BREAKING-CHANGE token without a new line
        // 5. <Any hypen seperatable word>:<space> or <Any hypen seperatable word><space>#  after a new line
        // 6. <Any hypen seperatable word>:<space> or <Any hypen seperatable word><space>#  without a new line
        let bodyParser = Parsers.Skip(StartsWith("\n"))
            .take(Parsers.OneOf(
                    PrefixUpToRegex<Substring>("[\\n]?(BREAKING CHANGE|BREAKING-CHANGE)"),
                    PrefixUpToRegex<Substring>("[\\n]?(((?=\\S*['-]?)([a-zA-Z'-]+):\\s)|((?=\\S*['-]?)([a-zA-Z'-]+)\\s\\#))")
            
            ))
        
        let footersParser = Parsers.Skip(Parsers.OptionalParser(StartsWith("\n")))
            .take(Many(singleFooterParser, separator: StartsWith("\n")))
        
        
        return headerParser
            .take(Parsers.OptionalParser(bodyParser))
            .take(Parsers.OptionalParser(footersParser))
            .map { header, body, footers in
                ConventionalCommit(header: header,
                                   body: convertSubstringToBody(substring: body)?.trimmingCharacters(in: .newlines),
                                   footers: footers == nil ? []: footers!
                )
            }
            .eraseToAnyParser()
    }()
    
    public init?(data: String) {
        guard let match = ConventionalCommit.parser.parse(data[...]) else {
            return nil
        }
        
        self = match
    }
    
    internal init(header: ConventionalCommit.Header, body: String?, footers: [ConventionalCommit.Footer]) {
        self._header = header
        self._body = body
        self._footers = footers
    }
}

// MARK: - Header
extension ConventionalCommit {
    internal struct Header {
        
        /// The type of commit
        let type: String
        
        /// Optional scope of the commit
        let scope: String?
        
        /// Flag for a breaking change commit
        let breaking: Bool
        
        /// Single line description of the contents of the commit
        let description: String
        
        /// A parser capable of parsing a `Header` of a `Substring`
        static let parser: AnyParser<Substring, Header> = {
            
            let anyScope = Prefix<Substring> {  $0 != "(" && $0 != ")" && !$0.isNewline }
                .flatMap {  $0.isEmpty ? Parsers.Fail().eraseToAnyParser(): Parsers.Always($0).eraseToAnyParser() }
                .eraseToAnyParser()
            
            let anyLetter = Prefix<Substring> { $0.isLetter }
                .flatMap {  $0.isEmpty ? Parsers.Fail().eraseToAnyParser(): Parsers.Always($0).eraseToAnyParser() }
                .eraseToAnyParser()

            let anyCharacter = Prefix<Substring> { $0.isLetter || $0.isWhitespace || $0.isSymbol || $0.isNumber }
                .flatMap {  $0.isEmpty ? Parsers.Fail().eraseToAnyParser(): Parsers.Always($0).eraseToAnyParser() }
                .eraseToAnyParser()

            let isBreaking = Parsers.OptionalParser(StartsWith<Substring>("!"))
                .flatMap { $0 != nil ? Parsers.Always(true) :  Parsers.Always(false)}
                .eraseToAnyParser()
            
            let type = anyLetter
            
            let scope = Skip(StartsWith<Substring>("("))
                .take(anyScope)
                .skip(StartsWith(")"))
                .eraseToAnyParser()
        
            return type
                .take(Parsers.OptionalParser(scope))
                .take(isBreaking)
                .skip(StartsWith<Substring>(": "))
                .take(Parsers.OneOf(PrefixThrough<Substring>("\n"), Parsers.Rest<Substring>()))
                .map { type, scope, isBreaking, description in
                    
                    //TODO: Trim the \n at the end of the description
                    Header(
                        type: String(type),
                        scope: scope == nil ? nil: String(scope!),
                        breaking: isBreaking,
                        description: description.trimmingCharacters(in: .newlines)
                    )
                }
                .eraseToAnyParser()
        }()
        
        internal init?(data: String) {
            guard let match = Header.parser.parse(data[...]) else {
                return nil
            }
            
            self = match
        }
        
        internal init(type: String, scope: String?, breaking: Bool, description: String) {
            self.type = type
            self.scope = scope
            self.breaking = breaking
            self.description = description
        }
    }
}


// MARK: - Footer
extension ConventionalCommit {
    public struct Footer {
       
        /// A free of choice word token
        public let wordToken: String
        
        /// String representation of the value of the word token
        public let value: String
        
        /// Flag for a breaking change commit
        public let isBreaking: Bool
        
        /// A parser capable of parsing a `Footer` of a `Substring`
        static let parser: AnyParser<Substring, Footer> = {
           
            let breakingWordToken = StartsWith<Substring>("BREAKING CHANGE")
                .map { _ in "BREAKING CHANGE"[...] }
                .eraseToAnyParser()
            
            let breakingWordHyphenToken = StartsWith<Substring>("BREAKING-CHANGE")
                .map { _ in "BREAKING-CHANGE"[...] }
                .eraseToAnyParser()
            
            let regularWordToken = Prefix<Substring> { $0.isLetter || $0 == "-" }
                .eraseToAnyParser()
            
            
            let colonSeparator = StartsWith<Substring>(": ").eraseToAnyParser()
            let hashTagSeparator = StartsWith<Substring>(" #").eraseToAnyParser()
             
            return Parsers.OneOfMany(breakingWordToken, breakingWordHyphenToken, regularWordToken)
                .skip(Parsers.OneOf(colonSeparator, hashTagSeparator))
                .take(Prefix { !$0.isNewline })
                .map { wordToken, value in
                    return Footer(wordToken: String(wordToken), value: String(value), isBreaking: String(wordToken) == "BREAKING CHANGE" || String(wordToken) == "BREAKING-CHANGE")
                }
                .eraseToAnyParser()
        }()
        
        internal init?(data: String) {
            guard let match = Footer.parser.parse(data[...]) else {
                return nil
            }
            
            self = match
        }
        
        internal init(wordToken: String, value: String, isBreaking: Bool) {
            self.wordToken = wordToken
            self.value = value
            self.isBreaking = isBreaking
        }
    }
}
