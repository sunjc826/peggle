import Foundation
import XCTest
@testable import PeggleClone
class PersistableObstacleTests: XCTestCase {
    var jsonStorage: JSONStorage!
    var triangle: TriangleObject!
    var obstacle: PersistableObstacle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        jsonStorage = JSONStorage()

        triangle = TriangleObject(center: CGPoint(x: 1, y: -1))
        obstacle = PersistableObstacle(shape: triangle, radiusOfOscillation: 2.5)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        jsonStorage = nil
        triangle = nil
        obstacle = nil
    }

    func testEncodeAndDecode_pegUnchanged() throws {
        let obstacleData = try jsonStorage.encode(object: obstacle)
        let decodedObstacle: PersistableObstacle = try jsonStorage.decode(data: obstacleData)

        XCTAssertEqual(decodedObstacle.shape.center, CGPoint(x: 1, y: -1))
        XCTAssertEqual(decodedObstacle.radiusOfOscillation, obstacle.radiusOfOscillation)
    }

    func testEquals_identical_returnsTrue() {
        XCTAssertEqual(obstacle, obstacle)
    }

    func testEquals_copyButNotIdentical_returnsFalse() {
        let obstacleCopy = PersistableObstacle(shape: obstacle.shape, radiusOfOscillation: obstacle.radiusOfOscillation)

        XCTAssertNotEqual(obstacleCopy, obstacle)
    }
}
