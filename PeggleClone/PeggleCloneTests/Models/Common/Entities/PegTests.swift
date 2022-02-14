import XCTest
@testable import PeggleClone

class PegTests: XCTestCase {
    var circle: Circle!
    var square: TransformablePolygonObject!
    var circularPeg: Peg!
    var squarePeg: Peg!
    override func setUpWithError() throws {
        try super.setUpWithError()

        circle = CircleObject(center: CGPoint.zero, radiusBeforeTransform: 1)
        square = TransformablePolygonObject(
            center: CGPoint.zero,
            polarVerticesRelativeToOwnCenterBeforeTransform: [
                PolarCoordinate(radius: sqrt(2), theta: Double.pi / 4),
                PolarCoordinate(radius: sqrt(2), theta: 3 * Double.pi / 4),
                PolarCoordinate(radius: sqrt(2), theta: 5 * Double.pi / 4),
                PolarCoordinate(radius: sqrt(2), theta: 7 * Double.pi / 4)
            ], sides: 4, scale: 1, rotation: 0
        )

        circularPeg = Peg(shape: circle, isCompulsory: false, isConcrete: false)
        squarePeg = Peg(shape: square, isCompulsory: true, isConcrete: true)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        circle = nil
        square = nil
        circularPeg = nil
        squarePeg = nil
    }

    func testInitWithInstance_valuesCopied() {
        let circularPegCopy = Peg(instance: circularPeg)
        let squarePegCopy = Peg(instance: squarePeg)

        XCTAssertEqual(circularPegCopy.isConcrete, circularPeg.isConcrete)
        XCTAssertEqual(circularPegCopy.isCompulsory, circularPeg.isCompulsory)
        XCTAssertTrue(circularPegCopy.shape is Circle)
        XCTAssertEqual(circularPegCopy.shape.center, circularPeg.shape.center)
        XCTAssertEqual(circularPegCopy.hasCollided, circularPeg.hasCollided)

        XCTAssertEqual(squarePegCopy.isConcrete, squarePeg.isConcrete)
        XCTAssertEqual(squarePegCopy.isCompulsory, squarePeg.isCompulsory)
        XCTAssertTrue(squarePegCopy.shape is TransformablePolygonObject)
        XCTAssertEqual(squarePegCopy.shape.center, squarePeg.shape.center)
        XCTAssertEqual(squarePegCopy.shape.sides, squarePeg.shape.sides)
        XCTAssertEqual(squarePegCopy.hasCollided, squarePegCopy.hasCollided)
    }

    func testCenterRelativeToBoundingBox() {
        XCTAssertEqual(circularPeg.centerRelativeToBoundingBox.x, 1, accuracy: floatingPointAccuracy)
        XCTAssertEqual(circularPeg.centerRelativeToBoundingBox.y, 1, accuracy: floatingPointAccuracy)

        XCTAssertEqual(squarePeg.centerRelativeToBoundingBox.x, 1, accuracy: floatingPointAccuracy)
        XCTAssertEqual(squarePeg.centerRelativeToBoundingBox.y, 1, accuracy: floatingPointAccuracy)
    }

    func testWithCenter_referenceNotCopied() {
        let newCircularPeg = circularPeg.withCenter(center: CGPoint.zero)

        XCTAssertNotIdentical(newCircularPeg, circularPeg)
    }

    func testWithCenter_centerChanged() {
        let newCircularPeg = circularPeg.withCenter(center: CGPoint(x: 1, y: 2))

        XCTAssertEqual(circularPeg.shape.center, CGPoint.zero)
        XCTAssertEqual(newCircularPeg.shape.center, CGPoint(x: 1, y: 2))
    }

    func testWithScale_referenceNotCopied() {
        let newCircularPeg = circularPeg.withScale(scale: 1)

        XCTAssertNotIdentical(newCircularPeg, circularPeg)
    }

    func testWithScale_scaleChanged() {
        let newCircularPeg = circularPeg.withScale(scale: 2)

        XCTAssertEqual(circularPeg.shape.scale, 1)
        XCTAssertEqual(newCircularPeg.shape.scale, 2)
    }

    func testWithRotation_referenceNotCopied() {
        let newSquarePeg = squarePeg.withRotation(rotation: 0)

        XCTAssertNotIdentical(newSquarePeg, squarePeg)
    }

    func testWithRotation_rotationChanged() {
        let newSquarePeg = squarePeg.withRotation(rotation: 1)

        XCTAssertEqual(squarePeg.shape.rotation, 0)
        XCTAssertEqual(newSquarePeg.shape.rotation, 1)
    }

    func testToPersistable() {
        let persistableCircularPeg = circularPeg.toPersistable()

        XCTAssert(persistableCircularPeg.shape is Circle)
        XCTAssertEqual(persistableCircularPeg.isCompulsory, circularPeg.isCompulsory)

        let persistableSquarePeg = squarePeg.toPersistable()

        XCTAssert(persistableSquarePeg.shape is TransformablePolygon)
        XCTAssertEqual(persistableSquarePeg.shape.sides, 4)
        XCTAssertEqual(persistableSquarePeg.isCompulsory, squarePeg.isCompulsory)
    }

    func testFromPersistable() {
        let recoveredCircularPeg = Peg.fromPersistable(persistablePeg: circularPeg.toPersistable())

        XCTAssert(recoveredCircularPeg.shape is Circle)
        XCTAssertEqual(recoveredCircularPeg.isCompulsory, circularPeg.isCompulsory)

        let recoveredSquarePeg = Peg.fromPersistable(persistablePeg: squarePeg.toPersistable())

        XCTAssert(recoveredSquarePeg.shape is TransformablePolygon)
        XCTAssertEqual(recoveredSquarePeg.shape.sides, 4)
        XCTAssertEqual(recoveredSquarePeg.isCompulsory, squarePeg.isCompulsory)
    }
}
