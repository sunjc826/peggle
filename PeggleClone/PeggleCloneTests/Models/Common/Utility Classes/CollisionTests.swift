//
//  CollisionTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng on 26/1/22.
//

import XCTest
@testable import PeggleClone

class CollisionTests: XCTestCase {
    var collision: Collision!

    override func setUpWithError() throws {
        try super.setUpWithError()

        collision = Collision()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        collision = nil
    }

    func testIsColliding_disjointCircles_returnsFalse() {
        let firstCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 10)
        let secondCircle = CircleObject(center: CGPoint(x: 0, y: 21), radiusBeforeTransform: 10)
        let thirdCircle = CircleObject(center: CGPoint(x: 21, y: 0), radiusBeforeTransform: 10)

        XCTAssertFalse(collision.isColliding(circle: firstCircle, otherCircle: secondCircle))
        XCTAssertFalse(collision.isColliding(circle: firstCircle, otherCircle: thirdCircle))
    }

    func testIsColliding_almostConnectedCircles_returnsFalse() {
        let firstCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 10)
        let secondCircle = CircleObject(center: CGPoint(x: 0, y: 20), radiusBeforeTransform: 9.99)
        let thirdCircle = CircleObject(center: CGPoint(x: 20, y: 0), radiusBeforeTransform: 9.99)

        XCTAssertFalse(collision.isColliding(circle: firstCircle, otherCircle: secondCircle))
        XCTAssertFalse(collision.isColliding(circle: firstCircle, otherCircle: thirdCircle))
    }

    func testIsColliding_overlappingCircles_returnsTrue() {
        let firstCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 10)
        let secondCircle = CircleObject(center: CGPoint(x: 0, y: 19), radiusBeforeTransform: 10)
        let thirdCircle = CircleObject(center: CGPoint(x: 19, y: 0), radiusBeforeTransform: 10)

        XCTAssertTrue(collision.isColliding(circle: firstCircle, otherCircle: secondCircle))
        XCTAssertTrue(collision.isColliding(circle: firstCircle, otherCircle: thirdCircle))
    }

    func testIsColliding_oneCircleInsideOfAnother_returnsTrue() {
        let firstCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 10)
        let secondCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 10)
        let thirdCircle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 9)

        XCTAssertTrue(collision.isColliding(circle: firstCircle, otherCircle: secondCircle))
        XCTAssertTrue(collision.isColliding(circle: firstCircle, otherCircle: thirdCircle))
    }

    // There is no real benefit to testing polygonal collision using
    // rectangles. Rectangles are mainly used due to ease of calculating
    // dimensions, whereas with a general convex polygon, it is harder.
    // One could also argue that as rectangles are axis-aligned, the
    // correctness may not generalize, and indeed this is true. Given more time,
    // I would test for general convex polygons as well.

    func testIsColliding_disjointRectangles_returnsFalse() {
        let firstRectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 11, y: 0), width: 10, height: 20)
        let thirdRectangle = RectangleObject(center: CGPoint(x: 0, y: 21), width: 10, height: 20)

        XCTAssertFalse(collision.isColliding(
            convexPolygon: firstRectangle,
            otherConvexPolygon: secondRectangle
        ))
        XCTAssertFalse(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: thirdRectangle))
    }

    func testIsColliding_almostConnectedRectangles_returnsFalse() {
        let firstRectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 10, y: 0), width: 9.99, height: 20)
        let thirdRectangle = RectangleObject(center: CGPoint(x: 0, y: 20), width: 10, height: 19.99)

        XCTAssertFalse(collision.isColliding(
            convexPolygon: firstRectangle,
            otherConvexPolygon: secondRectangle
        ))
        XCTAssertFalse(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: thirdRectangle))
    }

    func testIsColliding_overlappingRectangles_returnsTrue() {
        let firstRectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 9, y: 0), width: 10, height: 20)
        let thirdRectangle = RectangleObject(center: CGPoint(x: 0, y: 19), width: 10, height: 20)

        XCTAssertTrue(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: secondRectangle))
        XCTAssertTrue(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: thirdRectangle))
    }

    func testIsColliding_oneRectangleInsideOfAnother_returnsTrue() {
        let firstRectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)
        let thirdRectangle = RectangleObject(center: CGPoint.zero, width: 5, height: 10)

        XCTAssertTrue(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: secondRectangle))
        XCTAssertTrue(collision.isColliding(convexPolygon: firstRectangle, otherConvexPolygon: thirdRectangle))
    }

    func testIsColliding_disjointCircleAndRectangle_returnsFalse() {
        let circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 5)
        let firstRectangle = RectangleObject(center: CGPoint(x: 11, y: 0), width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 0, y: 16), width: 10, height: 20)

        XCTAssertFalse(collision.isColliding(circle: circle, convexPolygon: firstRectangle))
        XCTAssertFalse(collision.isColliding(circle: circle, convexPolygon: secondRectangle))
    }

    func testIsColliding_almostConnectedCircleAndRectangle_returnsFalse() {
        let circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 5)
        let firstRectangle = RectangleObject(center: CGPoint(x: 10, y: 0), width: 9.99, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 0, y: 15), width: 10, height: 19.99)

        XCTAssertFalse(collision.isColliding(circle: circle, convexPolygon: firstRectangle))
        XCTAssertFalse(collision.isColliding(circle: circle, convexPolygon: secondRectangle))
    }

    func testIsColliding_overlappingCircleAndRectangle_returnsTrue() {
        let circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 5)
        let firstRectangle = RectangleObject(center: CGPoint(x: 9, y: 0), width: 10, height: 20)
        let secondRectangle = RectangleObject(center: CGPoint(x: 0, y: 14), width: 10, height: 20)

        XCTAssertTrue(collision.isColliding(circle: circle, convexPolygon: firstRectangle))
        XCTAssertTrue(collision.isColliding(circle: circle, convexPolygon: secondRectangle))
    }

    func testIsColliding_circleInsideOfRectangle_returnsTrue() {
        let circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 5)
        let rectangle = RectangleObject(center: CGPoint.zero, width: 1, height: 1)

        XCTAssertTrue(collision.isColliding(circle: circle, convexPolygon: rectangle))
    }

    func testIsColliding_rectangleInsideOfCircle_returnsTrue() {
        let circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 1)
        let rectangle = RectangleObject(center: CGPoint.zero, width: 10, height: 20)

        XCTAssertTrue(collision.isColliding(circle: circle, convexPolygon: rectangle))
    }
}
