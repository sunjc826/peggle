import Foundation
import CoreGraphics

class GameObject: EditableGameEntity, Hashable {
    weak var rigidBody: RigidBodyObject?
    var isConcrete = true
    var shape: TransformableShape

    init(shape: TransformableShape, isConcrete: Bool) {
        self.shape = shape
        self.isConcrete = isConcrete
    }

    init(instance: GameObject) {
        isConcrete = instance.isConcrete
        switch instance.shape {
        case let circle as CircleObject:
            shape = CircleObject(instance: circle)
        case let polygon as TransformablePolygonObject:
            shape = TransformablePolygonObject(instance: polygon)
        default:
            fatalError(shapeCastingMessage)
        }
    }

    static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape.center)
    }

    func withCenter(center: CGPoint) -> GameObject {
        let copy = GameObject(instance: self)
        copy.shape.center = center
        return copy
    }

    func withScale(scale: Double) -> GameObject {
        let copy = GameObject(instance: self)
        copy.shape.scale = scale
        return copy
    }

    func withRotation(rotation: Double) -> GameObject {
        let copy = GameObject(instance: self)
        copy.shape.rotation = rotation
        return copy
    }
}

extension GameObject: HasBoundingBox {
    var boundingBox: BoundingBox {
        shape.boundingBox
    }

    var centerRelativeToBoundingBox: CGPoint {
        let boundingBox = self.boundingBox
        return CGPoint(x: boundingBox.leftWidth, y: boundingBox.topHeight)
    }
}
