//
//  ConventionalCommit.swift
//
//
//  Created by Alexander Weiß on 17.10.20.
//

import Parsing
import Foundation

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
               let str = String(substring!).trimmingCharacters(in: CharacterSet.newlines)

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
        let bodyParser: AnyParser<Substring, Substring> = Parse {
            Skip {
                Whitespace(2, .vertical)
            }
            OneOf {
                PrefixUpToRegex<Substring>("[\\n]?(BREAKING CHANGE|BREAKING-CHANGE)")
                PrefixUpToRegex<Substring>("[\\n]?(((?=\\S*['-]?)([a-zA-Z'-]+):\\s)|((?=\\S*['-]?)([a-zA-Z'-]+)\\s\\#))")
                PrefixUpTo("\n")
                Rest()
            }
        }.eraseToAnyParser()

        let footersParser: AnyParser<Substring, [Footer]> = Parse {
            Skip {
                Optionally { Whitespace(1, .vertical) }
            }
            Many {
                ConventionalCommit.Footer.parser
            } separator: {
                Whitespace(1, .vertical)
            }
        }.eraseToAnyParser()

        let parser = Parse {
            ConventionalCommit.Header.parser
            Optionally { bodyParser }
            Optionally { footersParser }
        }
        .map { (header, body, footers) in
            ConventionalCommit(
                header: header,
                body: convertSubstringToBody(substring: body),
                footers: footers ?? []
            )
        }
        .eraseToAnyParser()


        return parser
    }()

    // MARK: - Initializers
    internal init(header: ConventionalCommit.Header, body: String?, footers: [ConventionalCommit.Footer]) {
        self._header = header
        self._body = body
        self._footers = footers
    }

    internal init(input: String) throws {
        self = try Self.parser.parse(input)
    }
}
