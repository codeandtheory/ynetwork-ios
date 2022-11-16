//
//  String+regexTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

typealias RegexTestCase = (pattern: String, testCase: String)

final class StringRegexTests: XCTestCase {
    let matches: [RegexTestCase] = [
        ("^The", "The end is nigh!"),
        ("end$", "This is the end"),
        ("is", "This is the end."),
        ("abc*", "Now I know my abc's"),
        ("abc*'s$", "Now I know my abcc's"),
        ("abc*", "Now I know my abd's"),
        ("abc+", "Now I know my abc's"),
        ("abc+'s$", "Now I know my abcc's"),
        ("abc?", "Now I know my abc's"),
        ("abc?", "Now I know my abd's"),
        ("abc{2,5}'s$", "Now I know my abcc's"),
        ("abc{2,5}'s$", "Now I know my abccc's"),
        ("abc{2,5}'s$", "Now I know my abcccc's"),
        ("abc{2,5}'s$", "Now I know my abccccc's"),
        ("a(bc)+'s$", "Now I know my abc's"),
        ("a(bc)+'s$", "Now I know my abcbc's"),
        ("^#[a-fA-F0-9]{6}$", "#000000"),
        ("^#[a-fA-F0-9]{6}$", "#FFFFFF"),
        ("^#[a-fA-F0-9]{6}$", "#ffffff"),
        ("^#[a-fA-F0-9]{6}$", "#abad1d")
    ]
    
    let mismatches: [RegexTestCase] = [
        ("^The", "What? The end is nigh?"),
        ("end$", "This is not the end."),
        ("is", "That was not the end."),
        ("abc*", "Now I know my adc's"),
        ("abc+", "Now I know my abd's"),
        ("abc?'s$", "Now I know my abcc's"),
        ("abc{2,5}'s$", "Now I know my abc's"),
        ("abc{2,5}'s$", "Now I know my abcccccc's"),
        ("a(bc)+'s$", "Now I know my a's"),
        ("a(bc)?'s$", "Now I know my abcbcbc's"),
        ("^#[a-fA-F0-9]{6}$", "#OOOOOO"),
        ("^#[a-fA-F0-9]{6}$", "#FFFFF"),
        ("^#[a-fA-F0-9]{6}$", "#FFFFFFF"),
        ("^#[a-fA-F0-9]{6}$", "#FFFFFG"),
        ("^#[a-fA-F0-9]{6}$", "#abadid"),
        ("^#[a-fA-F0-9]{6}$", "#abad1dea")
    ]
    
    func testMatch() {
        matches.forEach {
            XCTAssertTrue(
                $0.testCase.matches(regex: $0.pattern),
                "Expected \($0.testCase) to match regex: \($0.pattern)"
            )
        }
    }
    
    func testMismatch() {
        mismatches.forEach {
            XCTAssertFalse(
                $0.testCase.matches(regex: $0.pattern),
                "Expected \($0.testCase) to not match regex: \($0.pattern)"
            )
        }
    }
}
