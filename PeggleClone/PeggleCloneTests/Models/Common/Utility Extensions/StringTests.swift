//
//  StringTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 30/1/22.
//

import XCTest
@testable import PeggleClone

class StringTests: XCTestCase {
    func testIsBlank_emptyString_returnsTrue() {
        let str = ""

        XCTAssertTrue(str.isBlank)
    }

    func testIsBlank_stringWithWhitespacesAndNewlinesOnly_returnsTrue() {
        let str = " \n     "

        XCTAssertTrue(str.isBlank)
    }

    func testIsBlank_nonEmptyString_returnsFalse() {
        let str = "123"

        XCTAssertFalse(str.isBlank)
    }

}
