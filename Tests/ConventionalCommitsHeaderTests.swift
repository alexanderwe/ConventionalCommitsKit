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
    
    func testNoScope() throws {
        let commitMessage = """
        fix: Fix iOS and tvOS versions
        """
        
        let commit = try ConventionalCommit.Header(input: commitMessage)
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testWithScope() throws {
        let commitMessage = """
        fix(ci): Fix iOS and tvOS versions
        """
        
        let commit = try ConventionalCommit.Header(input: commitMessage)
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChange() throws {
        let commitMessage = """
        fix!: Fix iOS and tvOS versions
        """
        
        let commit = try ConventionalCommit.Header(input: commitMessage)
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChangeWithScope() throws {
        let commitMessage = """
        fix(ci)!: Fix iOS and tvOS versions
        """
        
        let commit = try ConventionalCommit.Header(input: commitMessage)
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testMissingDescription() throws {
        let commitMessage = """
        fix(ci)!:
        """
        XCTAssertThrowsError(try ConventionalCommit.Header(input: commitMessage))
    }
    
    func testMissingType() throws {
        let commitMessage = """
        : Fix iOS and tvOS versions
        """

        let commit = try ConventionalCommit.Header(input: commitMessage)
        print(commit)

        XCTAssertThrowsError(try ConventionalCommit.Header(input: commitMessage))
    }
    
    static var allTests = [
        ("testNoScope", testNoScope),
        ("testWithScope", testWithScope),
        ("testBreakingChange", testBreakingChange),
        ("testBreakingChangeWithScope", testBreakingChangeWithScope),
        ("testMissingDescription", testMissingDescription),
        ("testMissingType", testMissingType),
    ]
}

