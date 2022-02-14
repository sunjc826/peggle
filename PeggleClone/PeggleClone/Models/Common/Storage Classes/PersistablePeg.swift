import Foundation
import CoreGraphics

final class PersistablePeg: Codable {
    let pegType: PegType
    let shape: TransformableShape

    init(shape: TransformableShape, pegType: PegType) {
        self.shape = shape
        self.pegType = pegType
    }

    private enum CodingKeys: String, CodingKey {
        case pegType
        case shape
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pegType, forKey: .pegType)
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
        pegType = try values.decode(PegType.self, forKey: .pegType)
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
