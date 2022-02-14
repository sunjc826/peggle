import XCTest
@testable import PeggleClone

class PolarCoordinateTests: XCTestCase {
    // Reference: https://stackoverflow.com/questions/4552683/in-unit-tests-how-do-you-handle-variable-naming-assignment
    // Denote multiple "non-meaningful" variables by prefixing with "any", and
    // differentiate them by suffix numbering
    func testToCartesian() {
        let anyCoord1 = PolarCoordinate(radius: 1, theta: 0)
        let anyCoord2 = PolarCoordinate(radius: 1, theta: Double.pi / 2)
        let anyCoord3 = PolarCoordinate(radius: 1, theta: -Double.pi / 2)

        XCTAssertEqual(anyCoord1.toCartesian(), CGPoint(x: 1, y: 0))

        XCTAssertEqual(anyCoord2.toCartesian().x, 0, accuracy: floatingPointAccuracy)

        XCTAssertEqual(anyCoord2.toCartesian().y, 1, accuracy: floatingPointAccuracy)

        XCTAssertEqual(anyCoord3.toCartesian().x, 0, accuracy: floatingPointAccuracy)

        XCTAssertEqual(anyCoord3.toCartesian().y, -1, accuracy: floatingPointAccuracy)
    }

    func testScaleBy() {
        let anyCoord1 = PolarCoordinate(radius: 1, theta: 1).scaleBy(factor: 0)
        let anyCoord2 = PolarCoordinate(radius: 0, theta: 1).scaleBy(factor: 2)
        let anyCoord3 = PolarCoordinate(radius: 1, theta: 1).scaleBy(factor: 2)

        XCTAssertEqual(anyCoord1, PolarCoordinate(radius: 0, theta: 1))
        XCTAssertEqual(anyCoord2, PolarCoordinate(radius: 0, theta: 1))
        XCTAssertEqual(anyCoord3, PolarCoordinate(radius: 2, theta: 1))
    }

    func testScaleTo() {
        let anyCoord = PolarCoordinate(radius: 2, theta: 1).scaleTo(factor: 10)
        XCTAssertEqual(anyCoord, PolarCoordinate(radius: 10, theta: 1))
    }

    func testRotate() {
        let anyCoord1 = PolarCoordinate(radius: 1, theta: 0).rotate(angle: 2)
        let anyCoord2 = PolarCoordinate(radius: 1, theta: Double.pi).rotate(angle: Double.pi)
        let anyCoord3 = PolarCoordinate(radius: 1, theta: -Double.pi).rotate(angle: Double.pi)

        XCTAssertEqual(anyCoord1, PolarCoordinate(radius: 1, theta: 2))
        XCTAssertEqual(anyCoord2.radius, 1)
        XCTAssert(doubleEqual(anyCoord2.theta, 0) || doubleEqual(anyCoord2.theta, 2 * Double.pi))
        XCTAssertEqual(anyCoord3.radius, 1)
        XCTAssert(doubleEqual(anyCoord3.theta, 0) || doubleEqual(anyCoord3.theta, 2 * Double.pi))
    }
}
