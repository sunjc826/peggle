import Foundation
import CoreGraphics

final class PersistablePeg: Codable {
    let isCompulsory: Bool
    let shape: TransformableShape

    init(shape: TransformableShape, isCompulsory: Bool) {
        self.shape = shape
        self.isCompulsory = isCompulsory
    }

    private enum CodingKeys: String, CodingKey {
        case isCompulsory
        case shape
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isCompulsory, forKey: .isCompulsory)
        switch shape {
        case let circle as CircleObject:
            try container.encode(circle, forKey: .shape)
        case let polygon as TransformablePolygonObject:
            try container.encode(polygon, forKey: .shape)
        default:
            fatalError(shapeCastingMessage)
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isCompulsory = try values.decode(Bool.self, forKey: .isCompulsory)
        do {
            shape = try values.decode(CircleObject.self, forKey: .shape)
        } catch {
            shape = try values.decode(TransformablePolygonObject.self, forKey: .shape)
        }
    }
}

extension PersistablePeg: Hashable {
    static func == (lhs: PersistablePeg, rhs: PersistablePeg) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape.center)
    }
}
