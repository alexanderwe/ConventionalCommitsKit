//
//  ConventionalCommitsTests.swift
//
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommitsKit

final class ConventionalCommitsTests: XCTestCase {

    // MARK: - Tests

    func testDescriptionAndNoBody() throws {
        // Given
        let commitMessage = "fix: Fix iOS and tvOS versions"

        // When
        let commit = try ConventionalCommit(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.isBreaking, false)
        XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 0)
    }

    func testDescriptionAndBody() throws {
        // Given
        let commitMessage = """
        fix(dependencies): Fix parsing library

        Update version dependencies
        """

        // When
        let commit = try ConventionalCommit(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.description, "Fix parsing library")
        XCTAssertEqual(commit.scope, "dependencies")
        XCTAssertEqual(commit.isBreaking, false)
        XCTAssertEqual(commit.body, "Update version dependencies")
        XCTAssertEqual(commit.footers.count, 0)
    }

    func testDescriptionAndBreakingChangeFooter() throws {
        // Given
        let commitMessage = """
        feat: allow provided config object to extend other configs

        BREAKING CHANGE: `extends` key in config file is now used for extending other config files
        """

        // When
        let commit = try ConventionalCommit(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "feat")
        XCTAssertEqual(commit.description, "allow provided config object to extend other configs")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.isBreaking, true)

        XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 1)
        XCTAssertEqual(commit.footers[0].isBreaking, true)
        XCTAssertEqual(commit.footers[0].wordToken, "BREAKING CHANGE")
        XCTAssertEqual(commit.footers[0].value, "`extends` key in config file is now used for extending other config files")
    }

    func testBreakingChangeHeaderWithFooter() throws {
        // Given
        let commitMessage = """
        refactor!: drop support for Node 6

        Reviewed-by #Z
        """

        // When
        let commit = try ConventionalCommit(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "refactor")
        XCTAssertEqual(commit.description, "drop support for Node 6")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.isBreaking, true)

        XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 1)
        XCTAssertEqual(commit.footers[0].isBreaking, false)
        XCTAssertEqual(commit.footers[0].wordToken, "Reviewed-by")
        XCTAssertEqual(commit.footers[0].value, "Z")
    }


    func testMultiParagraphBodyAndMultipleFooters() throws {
        // Given
        let commitMessage = """
        fix: correct minor typos in code

        see the issue for details

        on typos fixed.

        Reviewed-by #Z
        Refs #133
        """

        // When
        let commit = try ConventionalCommit(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.description, "correct minor typos in code")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.isBreaking, false)

        XCTAssertEqual(commit.body, """
        see the issue for details

        on typos fixed.
        """
        )
        XCTAssertEqual(commit.footers.count, 2)
        XCTAssertEqual(commit.footers[0].isBreaking, false)
        XCTAssertEqual(commit.footers[0].wordToken, "Reviewed-by")
        XCTAssertEqual(commit.footers[0].value, "Z")

        XCTAssertEqual(commit.footers.count, 2)
        XCTAssertEqual(commit.footers[1].isBreaking, false)
        XCTAssertEqual(commit.footers[1].wordToken, "Refs")
        XCTAssertEqual(commit.footers[1].value, "133")
    }
}
