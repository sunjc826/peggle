import XCTest
@testable import PeggleClone

class PersistableDesignerGameLevelTests: XCTestCase {
    var jsonStorage: JSONStorage!
    var designerGameLevel: PersistableDesignerGameLevel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        jsonStorage = JSONStorage()

        let levelName = "Hello world"
        let playArea = PlayArea(width: 10, height: 10, cannonZoneHeight: 1)
        let regularPolygon = RegularPolygonObject(center: CGPoint(x: 1, y: -1), radiusBeforeTransform: 3, sides: 5)
        let transformablePolygon = regularPolygon.getTransformablePolygon()

        let pegs: Set<PersistablePeg> = [
            PersistablePeg(shape: CircleObject(center: CGPoint.zero, radiusBeforeTransform: 1), isCompulsory: true),
            PersistablePeg(
                shape: CircleObject(center: CGPoint(x: 1, y: 2), radiusBeforeTransform: 2),
                isCompulsory: false
            ),
            PersistablePeg(shape: transformablePolygon, isCompulsory: false)
        ]

        designerGameLevel = PersistableDesignerGameLevel(
            levelName: levelName,
            pegs: pegs,
            playArea: playArea.toPersistable()
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        jsonStorage = nil
        designerGameLevel = nil
    }

    func testEncodeAndDecode_levelUnchanged() throws {
        let designerGameLevelData = try jsonStorage.encode(object: designerGameLevel)
        let decodedDesignerGameLevel: PersistableDesignerGameLevel = try jsonStorage.decode(data: designerGameLevelData)

        XCTAssertEqual(
            decodedDesignerGameLevel.levelName,
            designerGameLevel.levelName
        )

        XCTAssertEqual(
            decodedDesignerGameLevel.playArea.width,
            designerGameLevel.playArea.width
        )

        XCTAssertEqual(decodedDesignerGameLevel.playArea.height, designerGameLevel.playArea.height)

        XCTAssertEqual(decodedDesignerGameLevel.playArea.cannonZoneHeight, designerGameLevel.playArea.cannonZoneHeight)

        XCTAssertEqual(decodedDesignerGameLevel.pegs.count, 3)
    }

}
