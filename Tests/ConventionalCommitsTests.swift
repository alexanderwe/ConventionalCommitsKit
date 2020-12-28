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
    
    func testNoBody() throws {
        let commitMessage = """
        fix: Fix iOS and tvOS versions
        """

        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.isBreaking, false)
        XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 0)
    }
    
    func testDescriptionAndBreakingChangeFooter() throws {
        
        let commitMessage = """
        feat: allow provided config object to extend other configs

        BREAKING CHANGE: `extends` key in config file is now used for extending other config files
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
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
        
        let commitMessage = """
        refactor!: drop support for Node 6

        Reviewed-by: Z
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
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
        
        let commitMessage = """
        fix: correct minor typos in code

        see the issue for details

        on typos fixed.

        Reviewed-by #Z
        Refs #133
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
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
    
    
    static var allTests = [
        ("testNoBody", testNoBody),
        ("testDescriptionAndBreakingChangeFooter", testDescriptionAndBreakingChangeFooter),
        ("testBreakingChangeHeaderWithFooter", testBreakingChangeHeaderWithFooter),
        ("testMultiParagraphBodyAndMultipleFooters", testMultiParagraphBodyAndMultipleFooters)
    ]
}
