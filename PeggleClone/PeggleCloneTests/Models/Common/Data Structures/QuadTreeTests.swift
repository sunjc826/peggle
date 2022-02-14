import XCTest
@testable import PeggleClone

class QuadTreeTests: XCTestCase {
    var quadtree: QuadTree<Peg>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let boundingBox = BoundingBox(center: CGPoint.zero, width: 100, height: 100)
        quadtree = QuadTree<Peg>(bounds: boundingBox)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        quadtree = nil
    }

    func testInsert() {
        let anyPeg1 = Peg(
            shape: CircleObject(center: CGPoint(x: -49, y: -49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true)

        for i in 0..<8 {
            quadtree.insert(entity: Peg(instance: anyPeg1))
            XCTAssertEqual(quadtree!.debugDescription, "\(i + 1)")
        }

        let anyPeg2 = Peg(
            shape: CircleObject(center: CGPoint(x: 49, y: 49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true
        )

        quadtree.insert(entity: Peg(instance: anyPeg2))
        XCTAssertEqual(quadtree!.debugDescription, "[0:8,0,0,1]")
    }

    func testRetrieve() {
        let anyPeg1 = Peg(
            shape: CircleObject(center: CGPoint(x: -49, y: -49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true)
        let anyPeg2 = Peg(
            shape: CircleObject(center: CGPoint(x: 49, y: 49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true
        )
        let anyPeg3 = Peg(
            shape: CircleObject(center: CGPoint(x: 49, y: -49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true
        )
        let anyPeg4 = Peg(
            shape: CircleObject(center: CGPoint(x: -49, y: 49), radiusBeforeTransform: 0.1),
            isCompulsory: true,
            isConcrete: true
        )

        for _ in 0..<8 {
            quadtree.insert(entity: Peg(instance: anyPeg1))
        }

        quadtree.insert(entity: Peg(instance: anyPeg2))

        XCTAssertEqual(quadtree.retrievePotentialNeighbors(for: anyPeg1).getCount(), 8)
        XCTAssertEqual(quadtree.retrievePotentialNeighbors(for: anyPeg2).getCount(), 1)
        XCTAssertEqual(quadtree.retrievePotentialNeighbors(for: anyPeg3).getCount(), 0)
        XCTAssertEqual(quadtree.retrievePotentialNeighbors(for: anyPeg4).getCount(), 0)
    }
}

extension AnySequence {
    fileprivate func getCount() -> Int {
        var count = 0
        for _ in self {
            count += 1
        }
        return count
    }
}
