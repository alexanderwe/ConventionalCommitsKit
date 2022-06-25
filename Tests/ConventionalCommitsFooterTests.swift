//
//  ConventionalCommitsFooterTests.swift
//
//
//  Created by Alexander Weiß on 15.11.20.
//

import Foundation
import XCTest
import Parsing
@testable import ConventionalCommitsKit

/// Tests related to parsing footers of a conventional commit message
final class ConventionalCommitsFooterTests: XCTestCase {

    // MARK: - Tests

    func testSingleBreakingChange() throws {
        // Given
        let footerMessage = "BREAKING CHANGE: refactor to use JavaScript features not available in Node 6."

        // When
        let footer = try ConventionalCommit.Footer(input: footerMessage)

        // Then
        XCTAssertEqual(footer.wordToken, "BREAKING CHANGE")
        XCTAssertEqual(footer.value, "refactor to use JavaScript features not available in Node 6.")
        XCTAssertEqual(footer.isBreaking, true)
    }

    func testSingleBreakingChangeHypen() throws {
        // Given
        let footerMessage = "BREAKING-CHANGE: refactor to use JavaScript features not available in Node 6."

        // When
        let footer = try ConventionalCommit.Footer(input: footerMessage)

        // Then
        XCTAssertEqual(footer.wordToken, "BREAKING-CHANGE")
        XCTAssertEqual(footer.value, "refactor to use JavaScript features not available in Node 6.")
        XCTAssertEqual(footer.isBreaking, true)
    }

    func testSingleColonSeperated() throws {
        // Given
        let footerMessage = "Reviewed-by: Z"

        // When
        let footer = try ConventionalCommit.Footer(input: footerMessage)

        // Then
        XCTAssertEqual(footer.wordToken, "Reviewed-by")
        XCTAssertEqual(footer.value, "Z")
        XCTAssertEqual(footer.isBreaking, false)
    }

    func testSingleHashtagSeperated() throws {
        // Given
        let footerMessage = "Refs #133"

        // Then
        let footer = try ConventionalCommit.Footer(input: footerMessage)

        // When
        XCTAssertEqual(footer.wordToken, "Refs")
        XCTAssertEqual(footer.value, "133")
        XCTAssertEqual(footer.isBreaking, false)
    }


    func testMultipleFooters() throws {
        // Given
        let parser = Many {
            ConventionalCommit.Footer.parser
          } separator: {
              Whitespace(1, .vertical)
          }

        let footerMessage = """
        Reviewed-by: Z
        Refs #133
        """
        
        // When
        let footers = try parser.parse(footerMessage)

        // Then
        XCTAssertEqual(footers.count, 2)
        XCTAssertEqual(footers[0].wordToken , "Reviewed-by")
        XCTAssertEqual(footers[0].value , "Z")
        XCTAssertEqual(footers[1].wordToken , "Refs")
        XCTAssertEqual(footers[1].value , "133")
    }
}
