//
//  BoundingBoxTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng on 26/1/22.
//

import XCTest
import CoreGraphics
@testable import PeggleClone

class BoundingBoxTests: XCTestCase {
    var box = BoundingBox(center: CGPoint.zero, width: 10, height: 10)

    func testConstructor() {
        XCTAssertEqual(box.center, CGPoint.zero)
        XCTAssertEqual(box.width, 10)
        XCTAssertEqual(box.height, 10)
    }

    func testContainsPoint_pointInInteriorOfBox_returnsTrue() {
        XCTAssertTrue(box.contains(point: CGPoint.zero))
    }

    func testContainsPoint_pointOnBoundaryOfBox() {
        XCTAssertTrue(box.contains(point: CGPoint(x: 5, y: 5)))
    }

    func testContainsPoint_pointOutsideBox_returnsFalse() {
        XCTAssertFalse(box.contains(point: CGPoint(x: 5, y: 6)))
        XCTAssertFalse(box.contains(point: CGPoint(x: 6, y: 5)))
    }

    func testContainsBoundingBox_boxContainedWithin_returnsTrue() {
        let smallerBox = BoundingBox(center: CGPoint.zero, width: 5, height: 5)
        XCTAssertTrue(box.contains(boundingBox: smallerBox))
    }

    func testContainsBoundingBox_boxNotContainedWithin_returnsFalse() {
        let smallerButNotFullyContainedBox = BoundingBox(center: CGPoint(x: 6, y: 6), width: 5, height: 5)
        XCTAssertFalse(box.contains(boundingBox: smallerButNotFullyContainedBox))
    }
}
