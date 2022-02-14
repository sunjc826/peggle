import Foundation
import CoreGraphics

/// Represents a destructible object.
final class Peg: EditableGameEntity, Hashable {
    var isConcrete = true
    let isCompulsory: Bool
    let isDestructible = true
    let isOverlayable = false
    let shape: TransformableShape
    var hasCollided = false

    init(shape: TransformableShape, isCompulsory: Bool, isConcrete: Bool) {
        self.shape = shape
        self.isCompulsory = isCompulsory
        self.isConcrete = isConcrete
    }

    init(instance: Peg) {
        isCompulsory = instance.isCompulsory
        isConcrete = instance.isConcrete
        switch instance.shape {
        case let circle as CircleObject:
            shape = CircleObject(instance: circle)
        case let polygon as TransformablePolygonObject:
            shape = TransformablePolygonObject(instance: polygon)
        default:
            fatalError(shapeCastingMessage)
        }
        hasCollided = instance.hasCollided
    }

    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape.center)
    }
}

extension Peg: HasBoundingBox {
    var boundingBox: BoundingBox {
        shape.boundingBox
    }

    var centerRelativeToBoundingBox: CGPoint {
        let boundingBox = self.boundingBox
        return CGPoint(x: boundingBox.leftWidth, y: boundingBox.topHeight)
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

        return PersistablePeg(shape: shapeCopy, isCompulsory: isCompulsory)
    }

    static func fromPersistable(persistablePeg: PersistablePeg) -> Peg {
        Peg(shape: persistablePeg.shape, isCompulsory: persistablePeg.isCompulsory, isConcrete: true)
    }
}
