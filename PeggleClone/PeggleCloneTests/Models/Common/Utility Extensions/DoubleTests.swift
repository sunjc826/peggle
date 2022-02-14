//
//  DoubleTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 29/1/22.
//

import XCTest
@testable import PeggleClone
class DoubleTests: XCTestCase {
    let floatingPointAccuracy = 0.000_01

    func testGeneralizedMod_negativeNumber() {
        let x = -1.12
        let mod = x.generalizedMod(within: 0.1)
        XCTAssertEqual(mod, 0.08, accuracy: floatingPointAccuracy)
    }

    func testGeneralizedMod_positiveNumber() {
        let x = 1.12
        let mod = x.generalizedMod(within: 0.1)
        XCTAssertEqual(mod, 0.02, accuracy: floatingPointAccuracy)
    }

    func testGeneralizedMod_zero() {
        let x = 0.0
        let mod = x.generalizedMod(within: 0.1)

        XCTAssertEqual(mod, 0)
    }

}
