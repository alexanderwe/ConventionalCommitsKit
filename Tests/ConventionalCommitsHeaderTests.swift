//
//  ConventionalCommitsHeaderTests.swift
//  
//
//  Created by Alexander Weiß on 16.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommitsKit

/// Tests related to parsing footers of a conventional commit message
final class ConventionalCommitsHeaderTests: XCTestCase {

    // MARK: - Tests

    func testNoScope() throws {
        // Given
        let commitMessage = "fix: Fix iOS and tvOS versions"

        // When
        let commit = try ConventionalCommit.Header(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testWithScope() throws {
        // Given
        let commitMessage = "fix(ci): Fix iOS and tvOS versions"

        // When
        let commit = try ConventionalCommit.Header(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChange() throws {
        // Given
        let commitMessage = "fix!: Fix iOS and tvOS versions"

        // When
        let commit = try ConventionalCommit.Header(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChangeWithScope() throws {
        // Given
        let commitMessage = "fix(ci)!: Fix iOS and tvOS versions"

        // When
        let commit = try ConventionalCommit.Header(input: commitMessage)

        // Then
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testMissingDescription() throws {

        // Given
        let commitMessage = "fix(ci)!:"

        // Then
        XCTAssertThrowsError(try ConventionalCommit.Header(input: commitMessage))
    }
    
    func testMissingType() throws {
        // Given
        let commitMessage = ": Fix iOS and tvOS versions"

        // Then
        XCTAssertThrowsError(try ConventionalCommit.Header(input: commitMessage))
    }
}

