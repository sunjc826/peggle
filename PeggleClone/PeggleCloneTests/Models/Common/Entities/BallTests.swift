import XCTest
@testable import PeggleClone

class BallTests: XCTestCase {
    var ball: Ball!
    override func setUpWithError() throws {
        try super.setUpWithError()
        ball = Ball(
            center: CGPoint.zero,
            radiusBeforeTransform: 1.0
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        ball = nil
    }

    func testInitWithInstance_valuesCopied() {
        let ballCopy = Ball(instance: ball)

        XCTAssertEqual(ballCopy.center, ball.center)
        XCTAssertEqual(ballCopy.radiusBeforeTransform, ball.radiusBeforeTransform)
    }

    func testWithCenter_referenceNotCopied() {
        let newBall = ball.withCenter(center: CGPoint.zero)

        XCTAssertNotIdentical(newBall, ball)
    }

    func testWithCenter_centerChanged() {
        let newBall = ball.withCenter(center: CGPoint(x: 1, y: 2))

        XCTAssertEqual(newBall.center, CGPoint(x: 1, y: 2))
    }

    func testWithCenter_otherValuesNotChanged() {
        let newBall = ball.withCenter(center: CGPoint(x: 1, y: 2))

        XCTAssertEqual(newBall.scale, ball.scale)
        XCTAssertEqual(newBall.rotation, ball.rotation)
    }

    func testWithScale_referenceNotCopied() {
        let newBall = ball.withScale(scale: 1)

        XCTAssertNotIdentical(newBall, ball)
    }

    func testWithScale_scaleChanged() {
        let newBall = ball.withScale(scale: 2)

        XCTAssertEqual(newBall.scale, 2)
    }

    func testWithRotation_referenceNotCopied() {
        let newBall = ball.withRotation(rotation: 0)

        XCTAssertNotIdentical(newBall, ball)
    }

    func testWithRotation_rotationChanged() {
        let newBall = ball.withRotation(rotation: 1)

        XCTAssertEqual(newBall.rotation, 1)
    }
}
