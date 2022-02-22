import XCTest
@testable import PeggleClone

// PlayArea delegates most of its functionality off to BoundingBox.
// Hence, if tests for BoundingBox pass,
// we can be quite confident of its correctness,
// i.e. containsEntity and containsEntityStrictly

class PlayAreaTests: XCTestCase {
    var playArea: PlayArea!
    override func setUpWithError() throws {
        try super.setUpWithError()
        playArea = PlayArea(width: 10, height: 10, cannonZoneHeight: 1)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        playArea = nil
    }

    func testEqual_differentPlayAreaSize_returnsFalse() {
        let anyDifferentPlayArea1 = PlayArea(width: 10, height: 9, cannonZoneHeight: 1)

        let anyDifferentPlayArea2 = PlayArea(width: 9, height: 10, cannonZoneHeight: 1)

        XCTAssertNotEqual(playArea, anyDifferentPlayArea1)
        XCTAssertNotEqual(playArea, anyDifferentPlayArea2)
    }

    func testEqual_samePlayAreaSize_returnsTrue() {
        let anySamePlayArea = PlayArea(width: 10, height: 10, cannonZoneHeight: 1)

        XCTAssertEqual(playArea, anySamePlayArea)
    }
}
