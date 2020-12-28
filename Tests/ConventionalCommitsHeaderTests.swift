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
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testWithScope() throws {
        let commitMessage = """
        fix(ci): Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChange() throws {
        let commitMessage = """
        fix!: Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testBreakingChangeWithScope() throws {
        let commitMessage = """
        fix(ci)!: Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testMissingDescription() throws {
        let commitMessage = """
        fix(ci)!:
        """
        
        XCTAssertNil(ConventionalCommit.Header(data: commitMessage))
    }
    
    func testMissingType() throws {
        let commitMessage = """
        : Fix iOS and tvOS versions
        """
        
        XCTAssertNil(ConventionalCommit.Header(data: commitMessage))
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

