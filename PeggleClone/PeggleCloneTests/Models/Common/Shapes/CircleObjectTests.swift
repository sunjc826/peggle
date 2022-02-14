import XCTest
@testable import PeggleClone

class CircleObjectTests: XCTestCase {
    var circle: CircleObject!

    override func setUpWithError() throws {
        try super.setUpWithError()

        circle = CircleObject(
            center: CGPoint(x: 1, y: 2),
            radiusBeforeTransform: 2,
            scale: 3,
            rotation: 0
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        circle = nil
    }

    func testInitWithInstance_valuesCopied() {
        let copy = CircleObject(instance: circle)

        XCTAssertEqual(copy.center, circle.center)
        XCTAssertEqual(copy.radiusBeforeTransform, circle.radiusBeforeTransform)
        XCTAssertEqual(copy.scale, circle.scale)
        XCTAssertEqual(copy.rotation, circle.rotation)
    }
}
