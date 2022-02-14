import XCTest
@testable import PeggleClone
class PersistablePegTests: XCTestCase {
    var jsonStorage: JSONStorage!
    var circle: CircleObject!
    var transformableShape: TransformablePolygonObject!
    var circularPeg: PersistablePeg!
    var transformablePeg: PersistablePeg!

    override func setUpWithError() throws {
        try super.setUpWithError()
        jsonStorage = JSONStorage()

        circle = CircleObject(center: CGPoint(x: 1, y: 2), radiusBeforeTransform: 2)

        let regularPolygon = RegularPolygonObject(center: CGPoint(x: 1, y: -1), radiusBeforeTransform: 3, sides: 5)

        transformableShape = regularPolygon.getTransformablePolygon()

        circularPeg = PersistablePeg(shape: circle, isCompulsory: false)

        transformablePeg = PersistablePeg(shape: transformableShape, isCompulsory: true)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        jsonStorage = nil
        circle = nil
        transformableShape = nil
        circularPeg = nil
        transformablePeg = nil
    }

    func testEncodeAndDecode_pegUnchanged() throws {
        let circularPegData = try jsonStorage.encode(object: circularPeg)
        let decodedCircularPeg: PersistablePeg = try jsonStorage.decode(data: circularPegData)

        let transformablePegData = try jsonStorage.encode(object: transformablePeg)
        let decodedTransformablePeg: PersistablePeg = try jsonStorage.decode(data: transformablePegData)

        XCTAssertFalse(decodedCircularPeg.isCompulsory)
        XCTAssertEqual(decodedCircularPeg.shape.center, CGPoint(x: 1, y: 2))
        XCTAssert(decodedCircularPeg.shape is Circle)

        XCTAssertTrue(decodedTransformablePeg.isCompulsory)
        XCTAssertEqual(decodedTransformablePeg.shape.center, CGPoint(x: 1, y: -1))
        XCTAssert(decodedTransformablePeg.shape is TransformablePolygon)
    }

    func testEquals_identical_returnsTrue() {
        XCTAssertEqual(circularPeg, circularPeg)
        XCTAssertEqual(transformablePeg, transformablePeg)
    }

    func testEquals_copyButNotIdentical_returnsFalse() {
        let circularPegCopy = PersistablePeg(shape: circularPeg.shape, isCompulsory: circularPeg.isCompulsory)

        XCTAssertNotEqual(circularPeg, circularPegCopy)
    }
}
