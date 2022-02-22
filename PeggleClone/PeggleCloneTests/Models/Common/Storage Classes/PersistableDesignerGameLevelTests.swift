import XCTest
@testable import PeggleClone

class PersistableDesignerGameLevelTests: XCTestCase {
    var jsonStorage: JSONStorage!
    var pegs: Set<PersistablePeg>!
    var obstacles: Set<PersistableObstacle>!
    var designerGameLevel: PersistableDesignerGameLevel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        jsonStorage = JSONStorage()

        let levelName = "Hello world"
        let regularPolygon = RegularPolygonObject(center: CGPoint(x: 1, y: -1), radiusBeforeTransform: 3, sides: 5)
        let transformablePolygon = regularPolygon.getTransformablePolygon()

        pegs = [
            PersistablePeg(
                shape: CircleObject(center: CGPoint.zero, radiusBeforeTransform: 1),
                pegType: .compulsory
            ),
            PersistablePeg(
                shape: CircleObject(center: CGPoint(x: 1, y: 2), radiusBeforeTransform: 2),
                pegType: .optional
            ),
            PersistablePeg(
                shape: transformablePolygon,
                pegType: .special
            )
        ]

        obstacles = [
            PersistableObstacle(
                shape: TriangleObject(center: CGPoint.zero),
                radiusOfOscillation: 0.5
            ),
            PersistableObstacle(
                shape: TriangleObject(center: CGPoint(x: 1, y: 2)),
                radiusOfOscillation: 0.7
            ),
            PersistableObstacle(
                shape: TriangleObject(center: CGPoint(x: 1, y: -1)),
                radiusOfOscillation: 0.2
            )
        ]

        let coordinateMapper = PersistableCoordinateMapper(logicalWidth: 0.8, logicalHeight: 1.4)

        designerGameLevel = PersistableDesignerGameLevel(
            levelName: levelName,
            pegs: pegs,
            obstacles: obstacles,
            coordinateMapper: coordinateMapper
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        jsonStorage = nil
        pegs = nil
        obstacles = nil
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
            decodedDesignerGameLevel.coordinateMapper.logicalHeight,
            designerGameLevel.coordinateMapper.logicalHeight
        )

        XCTAssertEqual(
            decodedDesignerGameLevel.coordinateMapper.logicalWidth,
            designerGameLevel.coordinateMapper.logicalWidth
        )

        XCTAssertEqual(decodedDesignerGameLevel.pegs.count, 3)

        XCTAssertEqual(decodedDesignerGameLevel.obstacles.count, 3)

    }

}
