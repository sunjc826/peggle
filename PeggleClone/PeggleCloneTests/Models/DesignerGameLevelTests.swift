import XCTest
@testable import PeggleClone

class CollisionStubAlwaysReturnsTrue: CollisionDetector {
    func isColliding(circle: Circle, convexPolygon: Polygon) -> Bool {
        true
    }

    func isColliding(circle: Circle, otherCircle: Circle) -> Bool {
        true
    }

    func isColliding(convexPolygon: Polygon, otherConvexPolygon: Polygon) -> Bool {
        true
    }
}

class CollisionStubAlwaysReturnsFalse: CollisionDetector {
    func isColliding(circle: Circle, convexPolygon: Polygon) -> Bool {
        false
    }

    func isColliding(circle: Circle, otherCircle: Circle) -> Bool {
        false
    }

    func isColliding(convexPolygon: Polygon, otherConvexPolygon: Polygon) -> Bool {
        false
    }
}

class DesignerGameLevelTests: XCTestCase {
    var coordinateMapper: CoordinateMapper!
    var playArea: PlayArea!
    var container: SetObject<Peg>!
    var quadtree: QuadTree<Peg>!
    var collisionDetector: CollisionDetector!
    var designerGameLevel: DesignerGameLevel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coordinateMapper = CoordinateMapper(width: 100, height: 100, displayWidth: 100, displayHeight: 100)
        playArea = coordinateMapper.getPlayArea()
        container = SetObject<Peg>()
        quadtree = QuadTree<Peg>(bounds: playArea.boundingBox)
        collisionDetector = Collision()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        playArea = nil
        container = nil
        quadtree = nil
        collisionDetector = nil
        designerGameLevel = nil
    }

    func testAddPeg_noCollision_successfullyAdded() {
        designerGameLevel = DesignerGameLevel(
            coordinateMapper: coordinateMapper,
            container: container,
            neighborFinder: quadtree,
            collisionDetector: CollisionStubAlwaysReturnsFalse()
        )
        var pegAddCount = 0

        designerGameLevel.registerGameObjectDidAddCallback { _ in
            pegAddCount += 1
        }

        let anyPeg1 = Peg(
            shape: CircleObject(
                center: coordinateMapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 10, y: 20)),
                radiusBeforeTransform: 0.001
            ),
            isCompulsory: false,
            isConcrete: true
        )

        designerGameLevel.addGameObject(gameObject: anyPeg1)

        XCTAssertEqual(pegAddCount, 1)

        let anyPeg2 = Peg(
            shape: CircleObject(
                center: coordinateMapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 30, y: 10)),
                radiusBeforeTransform: 0.001
            ),
            isCompulsory: true,
            isConcrete: true
        )

        designerGameLevel.addGameObject(gameObject: anyPeg2)

        XCTAssertEqual(pegAddCount, 2)
    }

    func testAddPeg_collision_pegNotAdded() {
        designerGameLevel = DesignerGameLevel(
            coordinateMapper: coordinateMapper,
            container: container,
            neighborFinder: quadtree,
            collisionDetector: CollisionStubAlwaysReturnsTrue()
        )

        var pegAddCount = 0

        designerGameLevel.registerGameObjectDidAddCallback { _ in
            pegAddCount += 1
        }

        let anyPeg1 = Peg(
            shape: CircleObject(
                center: coordinateMapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 10, y: 20)),
                radiusBeforeTransform: 0.001
            ),
            isCompulsory: false,
            isConcrete: true
        )

        designerGameLevel.addGameObject(gameObject: anyPeg1)

        XCTAssertEqual(pegAddCount, 1)

        let anyPeg2 = Peg(
            shape: CircleObject(
                center: coordinateMapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 30, y: 10)),
                radiusBeforeTransform: 0.001
            ),
            isCompulsory: true,
            isConcrete: true
        )

        designerGameLevel.addGameObject(gameObject: anyPeg2)

        XCTAssertEqual(pegAddCount, 1)
    }

    func testRemovePeg_pegExists_successfullyRemoved() {
        designerGameLevel = DesignerGameLevel(
            coordinateMapper: coordinateMapper,
            container: container,
            neighborFinder: quadtree,
            collisionDetector: collisionDetector
        )

        var pegRemoveCount = 0

        designerGameLevel.registerGameObjectDidRemoveCallback { _ in
            pegRemoveCount += 1
        }

        let anyPeg = Peg(
            shape: CircleObject(
                center: coordinateMapper.getLogicalCoords(ofDisplayCoords: CGPoint(x: 10, y: 20)),
                radiusBeforeTransform: 0.001
            ),
            isCompulsory: false,
            isConcrete: true
        )
        designerGameLevel.addGameObject(gameObject: anyPeg)
        designerGameLevel.removePeg(peg: anyPeg)

        XCTAssertEqual(pegRemoveCount, 1)
    }
}
