//
//  UtilityExtensionsTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng on 26/1/22.
//

import XCTest
@testable import PeggleClone

class ArrayTests: XCTestCase {
    private class ReferenceObject {}
    private func factory() -> ReferenceObject {
        ReferenceObject()
    }

    func testInit_repeatCountCorrect() {
        let count = 10
        let arr = Array(repeatingFactory: factory, count: count)

        XCTAssertEqual(arr.count, count)
    }

    func testInit_distinctItemsProduced() {
        let arr = Array(repeatingFactory: factory, count: 2)

        XCTAssertNotIdentical(arr[0], arr[1])
    }

    func testGetExtrema_success() {
        let points = [
            CGPoint(x: 1, y: 2),
            CGPoint(x: -1, y: 5),
            CGPoint(x: 3, y: -10)
        ]

        let extrema = points.getExtrema()

        XCTAssertEqual(extrema.minX, -1)
        XCTAssertEqual(extrema.maxX, 3)
        XCTAssertEqual(extrema.minY, -10)
        XCTAssertEqual(extrema.maxY, 5)
    }

}
