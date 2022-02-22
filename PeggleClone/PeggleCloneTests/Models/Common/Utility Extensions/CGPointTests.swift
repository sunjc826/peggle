//
//  CGPointTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 29/1/22.
//

import XCTest
@testable import PeggleClone

class CGPointTests: XCTestCase {

    func testFromVector() {
        let v = CGVector(dx: 1, dy: -2)
        let p = CGPoint.fromVector(vector: v)

        XCTAssertEqual(p.x, 1)
        XCTAssertEqual(p.y, -2)
    }

    func testTranslateWithComponents() {
        let point = CGPoint(x: 0, y: 0)
        let translatedPoint = point.translate(dx: 1, dy: -1)
        XCTAssertEqual(translatedPoint.x, 1)
        XCTAssertEqual(translatedPoint.y, -1)
    }

    func testTranslateWithOffset() {
        let point = CGPoint(x: 0, y: 0)
        let translatedPoint = point.translate(offset: CGVector(dx: 1, dy: -1))
        XCTAssertEqual(translatedPoint.x, 1)
        XCTAssertEqual(translatedPoint.y, -1)
    }

    func testTranslateUniform() {
        let point = CGPoint(x: 0, y: 0)
        let translatedPoint = point.translate(uniform: -1)
        XCTAssertEqual(translatedPoint.x, -1)
        XCTAssertEqual(translatedPoint.y, -1)
    }

    func testTranslateX() {
        let point = CGPoint(x: 0, y: 0)
        let translatedPoint = point.translateX(dx: 1)
        XCTAssertEqual(translatedPoint.x, 1)
        XCTAssertEqual(translatedPoint.y, 0)
    }

    func testTranslateY() {
        let point = CGPoint(x: 0, y: 0)
        let translatedPoint = point.translateY(dy: 1)
        XCTAssertEqual(translatedPoint.x, 0)
        XCTAssertEqual(translatedPoint.y, 1)
    }

    func testScaleAboutOrigin() {
        let point = CGPoint(x: 1, y: 0)
        let scaledPoint = point.scaleAboutOrigin(factor: 5)
        XCTAssertEqual(scaledPoint.x, 5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(scaledPoint.y, 0)
    }

    func testScaleAboutOriginWithComponents() {
        let point = CGPoint(x: 1, y: 1)
        let scaledPoint = point.scaleAboutOrigin(factorX: 5, factorY: 10)
        XCTAssertEqual(scaledPoint.x, 5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(scaledPoint.y, 10, accuracy: floatingPointAccuracy)
    }

    func testNorm_zeroVector() {
        XCTAssertEqual(CGPoint.zero.norm, 0)
    }

    func testNorm_nonZeroVector() {
        XCTAssertEqual(CGPoint(x: 3, y: 4).norm, 5, accuracy: floatingPointAccuracy)
    }

    func testDistanceTo() {
        let origin = CGPoint.zero
        let point = CGPoint(x: 3, y: 4)
        XCTAssertEqual(point.distanceTo(point: origin), 5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(origin.distanceTo(point: point), 5, accuracy: floatingPointAccuracy)
    }

    func testDistanceToWithComponents() {
        let origin = CGPoint.zero
        let point = CGPoint(x: 3, y: 4)
        XCTAssertEqual(point.distanceTo(x: 0, y: 0), 5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(origin.distanceTo(x: 3, y: 4), 5, accuracy: floatingPointAccuracy)
    }
}
