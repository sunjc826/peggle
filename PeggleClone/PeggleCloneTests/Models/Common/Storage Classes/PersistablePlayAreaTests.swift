import XCTest
@testable import PeggleClone

class PersistablePlayAreaTests: XCTestCase {
    var jsonStorage: JSONStorage!
    override func setUpWithError() throws {
        try super.setUpWithError()

        jsonStorage = JSONStorage()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        jsonStorage = nil
    }

    func testAndDecode_playAreaUnchanged() throws {
        let playArea = PersistablePlayArea(width: 10, height: 10, cannonZoneHeight: 1)
        let playAreaData = try jsonStorage.encode(object: playArea)
        let decodedPlayArea: PersistablePlayArea = try jsonStorage.decode(data: playAreaData)

        XCTAssertEqual(decodedPlayArea.width, playArea.width)
        XCTAssertEqual(decodedPlayArea.height, playArea.height)
        XCTAssertEqual(decodedPlayArea.cannonZoneHeight, playArea.cannonZoneHeight)
    }
}
