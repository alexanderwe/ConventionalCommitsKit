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
    
    func testSingleBreakingChange() throws {
        
        let footerMessage = "BREAKING CHANGE: refactor to use JavaScript features not available in Node 6."
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "BREAKING CHANGE")
        XCTAssertEqual(footer.value, "refactor to use JavaScript features not available in Node 6.")
        XCTAssertEqual(footer.isBreaking, true)
    }
    
    func testSingleBreakingChangeHypen() throws {
        let footerMessage = "BREAKING-CHANGE: refactor to use JavaScript features not available in Node 6."
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "BREAKING-CHANGE")
        XCTAssertEqual(footer.value, "refactor to use JavaScript features not available in Node 6.")
        XCTAssertEqual(footer.isBreaking, true)
    }
    
    func testSingleColonSeperated() throws {
        
        let footerMessage = "Reviewed-by: Z"
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "Reviewed-by")
        XCTAssertEqual(footer.value, "Z")
        XCTAssertEqual(footer.isBreaking, false)
    }
    
    func testSingleHashtagSeperated() throws {
        
        let footerMessage = "Refs #133"
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "Refs")
        XCTAssertEqual(footer.value, "133")
        XCTAssertEqual(footer.isBreaking, false)
    }
    
    
    func testMultipleFooters() throws {
        
        let parser = Parsers.Many(ConventionalCommit.Footer.parser, separator: StartsWith("\n"))
           
        let footerMessage = """
        Reviewed-by: Z
        Refs #133
        """
        
        let footers = try XCTUnwrap(parser.parse(footerMessage[...]))
        
        XCTAssertEqual(footers.count, 2)
        XCTAssertEqual(footers[0].wordToken , "Reviewed-by")
        XCTAssertEqual(footers[0].value , "Z")
        XCTAssertEqual(footers[1].wordToken , "Refs")
        XCTAssertEqual(footers[1].value , "133")
    }
    
    static var allTests = [
        ("testSingleBreakingChange", testSingleBreakingChange),
        ("testSingleBreakingChangeHypen", testSingleBreakingChangeHypen),
        ("testSingleColonSeperated", testSingleColonSeperated),
        ("testSingleHashtagSeperated", testSingleHashtagSeperated),
        ("testMultipleFooters", testMultipleFooters),
    ]
}
