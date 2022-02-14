//
//  CGVectorTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 29/1/22.
//

import XCTest
@testable import PeggleClone

class CGVectorTests: XCTestCase {

    func testFromPoint() {
        let point = CGPoint(x: 1, y: -1)
        let vector = CGVector.fromPoint(point: point)

        XCTAssertEqual(vector.dx, 1)
        XCTAssertEqual(vector.dy, -1)
    }

    func testGetPositionVector() {
        let point = CGPoint(x: 1, y: -1)
        let vector = CGVector.getPositionVector(of: point)

        XCTAssertEqual(vector.dx, 1)
        XCTAssertEqual(vector.dy, -1)
    }

    func testTranslateWithComponents() {
        let vector = CGVector.zero
        let translatedVector = vector.translate(x: 1, y: -1)

        XCTAssertEqual(translatedVector.dx, 1)
        XCTAssertEqual(translatedVector.dy, -1)
    }

    func testTranslate() {
        let vector = CGVector.zero
        let translatedVector = vector.translate(offset: CGVector(dx: 1, dy: -1))

        XCTAssertEqual(translatedVector.dx, 1)
        XCTAssertEqual(translatedVector.dy, -1)
    }

    func testTranslateUniform() {
        let vector = CGVector.zero
        let translatedVector = vector.translate(uniform: -1)

        XCTAssertEqual(translatedVector.dx, -1)
        XCTAssertEqual(translatedVector.dy, -1)
    }

    func testTranslateX() {
        let vector = CGVector.zero
        let translatedVector = vector.translateX(x: -1)

        XCTAssertEqual(translatedVector.dx, -1)
        XCTAssertEqual(translatedVector.dy, 0)
    }

    func testTranslateY() {
        let vector = CGVector.zero
        let translatedVector = vector.translateY(y: -1)

        XCTAssertEqual(translatedVector.dx, 0)
        XCTAssertEqual(translatedVector.dy, -1)
    }

    func testScaleBy_zeroVector() {
        let vector = CGVector.zero
        let scaledVector = vector.scaleBy(factor: 10)

        XCTAssertEqual(scaledVector.dx, 0)
        XCTAssertEqual(scaledVector.dy, 0)
    }

    func testScaleBy_nonZeroVector() {
        let vector = CGVector(dx: 1, dy: 1)
        let scaledVector = vector.scaleBy(factor: 10)

        XCTAssertEqual(scaledVector.dx, 10)
        XCTAssertEqual(scaledVector.dy, 10)
    }

    func testScaleTo() {
        let vector = CGVector(dx: 0, dy: 0.1)
        let scaledVector = vector.scaleTo(length: 5)

        XCTAssertEqual(scaledVector.dx, 0, accuracy: floatingPointAccuracy)
        XCTAssertEqual(scaledVector.dy, 5, accuracy: floatingPointAccuracy)
    }

    func testScale() {
        let vector = CGVector(dx: 1, dy: 1)
        let scaledVector = vector.scale(factorX: 2, factorY: -1)

        XCTAssertEqual(scaledVector.dx, 2, accuracy: floatingPointAccuracy)
        XCTAssertEqual(scaledVector.dy, -1, accuracy: floatingPointAccuracy)
    }

    func testReverse() {
        let vector = CGVector(dx: 1, dy: -1)
        let reversedVector = vector.reverse()

        XCTAssertEqual(reversedVector.dx, -1, accuracy: floatingPointAccuracy)
        XCTAssertEqual(reversedVector.dy, 1, accuracy: floatingPointAccuracy)
    }

    func testNormalize() {
        let vector = CGVector(dx: 10, dy: 0)
        let normalizedVector = vector.normalize()

        XCTAssertEqual(normalizedVector.dx, 1, accuracy: floatingPointAccuracy)
        XCTAssertEqual(normalizedVector.dy, 0, accuracy: floatingPointAccuracy)
    }

    func testNorm() {
        let vector = CGVector(dx: 3, dy: 4)

        XCTAssertEqual(vector.norm, 5, accuracy: floatingPointAccuracy)
    }
}
