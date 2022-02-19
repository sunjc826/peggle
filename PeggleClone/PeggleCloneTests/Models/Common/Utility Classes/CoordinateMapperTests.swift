import XCTest
@testable import PeggleClone

class CoordinateMapperTests: XCTestCase {
    var mapper: CoordinateMapper!
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        mapper = nil
    }

    func testMapperInit_displayAspectRatioHigher_widthTruncated() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )
        XCTAssertEqual(mapper.displayWidth, 20, accuracy: floatingPointAccuracy)
        XCTAssertEqual(mapper.displayHeight, 40, accuracy: floatingPointAccuracy)
    }

    func testMapperInit_displayAspectRatioLower_heightTruncated() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 5, onScreenDisplayHeight: 40
        )
        XCTAssertEqual(mapper.displayWidth, 5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(mapper.displayHeight, 10, accuracy: floatingPointAccuracy)
    }

    func testGetDisplayCoords() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )

        let displayCoords = mapper.getDisplayCoords(ofLogicalCoords: CGPoint(x: 0.1, y: 0.1))
        XCTAssertEqual(displayCoords.x, 4, accuracy: floatingPointAccuracy)
        XCTAssertEqual(displayCoords.y, 4, accuracy: floatingPointAccuracy)
    }

    func testGetLogicalCoords() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )

        let logicalCoords = mapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 20, y: 20))
        XCTAssertEqual(logicalCoords.x, 0.5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(logicalCoords.y, 0.5, accuracy: floatingPointAccuracy)
    }

    func testGetDisplayVector() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )
        let displayVector = mapper.getDisplayVector(ofLogicalVector: CGVector(dx: 0.1, dy: 0.1))
        XCTAssertEqual(displayVector.dx, 4, accuracy: floatingPointAccuracy)
        XCTAssertEqual(displayVector.dy, 4, accuracy: floatingPointAccuracy)
    }

    func testGetLogicalVector() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )
        let logicalVector = mapper.getLogicalVector(ofDisplayVector: CGVector(dx: 20, dy: 20))
        XCTAssertEqual(logicalVector.dx, 0.5, accuracy: floatingPointAccuracy)
        XCTAssertEqual(logicalVector.dy, 0.5, accuracy: floatingPointAccuracy)
    }

    func testGetDisplayLength() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )

        let displayLength = mapper.getDisplayLength(ofLogicalLength: 0.1)
        XCTAssertEqual(displayLength, 4, accuracy: floatingPointAccuracy)
    }

    func testGetLogicalLength() {
        mapper = CoordinateMapper(
            targetDisplayWidth: 10, targetDisplayHeight: 20, onScreenDisplayWidth: 100, onScreenDisplayHeight: 40
        )

        let logicalLength = mapper.getLogicalLength(ofDisplayLength: 20)
        XCTAssertEqual(logicalLength, 0.5, accuracy: floatingPointAccuracy)
    }
}
