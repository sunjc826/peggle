import Foundation
import CoreGraphics

/// Represents a destructible object.
final class Peg: GameObject {
    var pegType: PegType
    var hasCollided = false

    init(shape: TransformableShape, pegType: PegType, isConcrete: Bool) {
        self.pegType = pegType
        super.init(shape: shape, isConcrete: isConcrete)
    }

    init(instance: Peg) {
        pegType = instance.pegType
        hasCollided = instance.hasCollided
        super.init(instance: instance)
    }

    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs === rhs
    }
}

extension Peg {
    func withCenter(center: CGPoint) -> Peg {
        let copy = Peg(instance: self)
        copy.shape.center = center
        return copy
    }

    func withScale(scale: Double) -> Peg {
        let copy = Peg(instance: self)
        copy.shape.scale = scale
        return copy
    }

    func withRotation(rotation: Double) -> Peg {
        let copy = Peg(instance: self)
        copy.shape.rotation = rotation
        return copy
    }

    func withHasCollided(hasCollided: Bool) -> Peg {
        let copy = Peg(instance: self)
        copy.hasCollided = hasCollided
        return copy
    }

    func withPegType(pegType: PegType) -> Peg {
        let copy = Peg(instance: self)
        copy.pegType = pegType
        return copy
    }
}

// MARK: Persistable
extension Peg {
    func toPersistable() -> PersistablePeg {
        let shapeCopy: TransformableShape
        switch shape {
        case let circle as CircleObject:
            shapeCopy = CircleObject(instance: circle)
        case let polygon as TransformablePolygonObject:
            shapeCopy = TransformablePolygonObject(instance: polygon)
        default:
            fatalError(shapeCastingMessage)
        }

        return PersistablePeg(shape: shapeCopy, pegType: pegType)
    }

    static func fromPersistable(persistablePeg: PersistablePeg) -> Peg {
        Peg(shape: persistablePeg.shape, pegType: persistablePeg.pegType, isConcrete: true)
    }
}
