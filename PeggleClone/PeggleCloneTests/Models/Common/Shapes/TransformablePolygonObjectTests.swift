import XCTest
@testable import PeggleClone

class TransformablePolygonObjectTests: XCTestCase {
    var polygon: TransformablePolygonObject!

    override func setUpWithError() throws {
        try super.setUpWithError()

        polygon = TransformablePolygonObject(
            center: CGPoint(x: 1, y: 2),
            polarVerticesRelativeToOwnCenterBeforeTransform: [
                PolarCoordinate(radius: 1, theta: 0.1),
                PolarCoordinate(radius: 2, theta: 0.2),
                PolarCoordinate(radius: 1.5, theta: Double.pi),
                PolarCoordinate(radius: 0.5, theta: 5 * Double.pi / 4),
                PolarCoordinate(radius: 3, theta: 7 * Double.pi / 4)
            ],
            sides: 5,
            scale: 2,
            rotation: 2
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        polygon = nil
    }

    func testInitWithInstance_valuesCopied() {
        let copy = TransformablePolygonObject(instance: polygon)

        XCTAssertEqual(copy.center, polygon.center)
        XCTAssertEqual(
            copy.polarVerticesRelativeToOwnCenterBeforeTransform,
            polygon.polarVerticesRelativeToOwnCenterBeforeTransform
        )
        XCTAssertEqual(copy.scale, polygon.scale)
        XCTAssertEqual(copy.rotation, polygon.rotation)
    }

}
