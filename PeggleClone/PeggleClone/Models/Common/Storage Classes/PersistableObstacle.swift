import Foundation
import CoreGraphics

final class PersistableObstacle: Codable {
    let shape: TriangleObject
    var radiusOfOscillation: Double

    init(shape: TriangleObject, radiusOfOscillation: Double) {
        self.shape = shape
        self.radiusOfOscillation = radiusOfOscillation
    }

    private enum CodingKeys: String, CodingKey {
        case shape
        case radiusOfOscillation
    }
}

extension PersistableObstacle: Hashable {
    static func == (lhs: PersistableObstacle, rhs: PersistableObstacle) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape.center)
    }
}
