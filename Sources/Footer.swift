//
//  Footer.swift
//  
//
//  Created by Weiss, Alexander on 06.06.22.
//

import Foundation
import Parsing


extension ConventionalCommit {
    public struct Footer {

        /// A free of choice word token
        public let wordToken: String

        /// String representation of the value of the word token
        public let value: String

        /// Flag for a breaking change commit
        public let isBreaking: Bool

        // MARK: - Parser

        /// A parser capable of parsing a `Footer` of a `Substring`
        static let parser: AnyParser<Substring, Footer> = {

            let wordToken = Prefix<Substring> { $0.isLetter || $0.isNumber || $0.isSymbol || $0 == "-" }
                .eraseToAnyParser()

            let seperator = OneOf {
                ": "
                " #"
            }

            let rest = Prefix<Substring> { !$0.isWhitespace }

            let footer = Parse {
                wordToken
                seperator
                rest
            }.map { wordToken, value in
                return Footer(
                    wordToken: String(wordToken),
                    value: String(value),
                    isBreaking: String(wordToken) == "BREAKING CHANGE" || String(wordToken) == "BREAKING-CHANGE"
                )
            }

            return footer.eraseToAnyParser()
        }()

        // MARK: - Initializers
        internal init(wordToken: String, value: String, isBreaking: Bool) {
            self.wordToken = wordToken
            self.value = value
            self.isBreaking = isBreaking
        }

        internal init(input: String) throws {
            self = try Self.parser.parse(input)
        }
    }
}
