import Foundation
import CoreGraphics

class GameObject: GameEntity, Hashable {
    weak var rigidBody: RigidBody?
    var shape: TransformableShape

    init(shape: TransformableShape) {
        self.shape = shape
    }

    init(instance: GameObject) {
        switch instance.shape {
        case let circle as CircleObject:
            shape = CircleObject(instance: circle)
        case let triangle as TriangleObject:
            shape = TriangleObject(instance: triangle)
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
