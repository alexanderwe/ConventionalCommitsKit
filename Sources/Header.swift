//
//  Header.swift
//  
//
//  Created by Weiss, Alexander on 05.06.22.
//

import Foundation
import Parsing


struct EmptyFailure: Error {}

extension ConventionalCommit {

    struct Header {

        // MARK: - Properties

        /// The type of commit
        let type: String

        /// Optional scope of the commit
        let scope: String?

        /// Flag for a breaking change commit
        let breaking: Bool

        /// Single line description of the contents of the commit
        let description: String

        // MARK: - Parser

        /// A parser capable of parsing a `Header` of a `Substring`
        static let parser: AnyParser<Substring, Header> = {

            let type = Prefix { $0.isLetter }
                .map(String.init)
                .flatMap {
                    if $0.isEmpty {
                        Fail<Substring, String>(throwing: EmptyFailure())
                    } else {
                        Always($0)
                    }
                }

            let scope =  Optionally {
                Parse {
                    "("
                    Prefix { $0.isLetter || $0.isNumber || $0.isSymbol }
                    ")"
                }
            }
            .map { $0 != nil ? String($0!) : nil }

            let isBreaking =  Optionally { "!" }
                .map { $0 != nil ? true : false }

            let header = Parse(Header.init(type:scope:breaking:description:)) {
                type
                scope
                isBreaking
                ": "
                Rest().map(String.init)
            }

            return header.eraseToAnyParser()
        }()

        // MARK: - Initializers
        internal init(type: String, scope: String? = nil, breaking: Bool, description: String) {
            self.type = type
            self.scope = scope
            self.breaking = breaking
            self.description = description
        }

        internal init(input: String) throws {
            self = try Self.parser.parse(input)
        }

    }
}
