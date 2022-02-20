import Foundation
import CoreGraphics

/// Represents an indestructible object. It does not interact with any pegs and only interacts with the ball.
/// Due to being dynamically resizable, to ensure convexity its shape is restricted to that of a triangle.
final class Obstacle: GameObject {
    var radiusOfOscillation: Double

    init(shape: TriangleObject, radiusOfOscillation: Double, isConcrete: Bool) {
        self.radiusOfOscillation = radiusOfOscillation
        super.init(shape: shape, isConcrete: isConcrete)
    }

    init(instance: Obstacle) {
        radiusOfOscillation = instance.radiusOfOscillation
        super.init(instance: instance)
    }

    override func withCenter(center: CGPoint) -> Obstacle {
        let copy = Obstacle(instance: self)
        copy.shape.center = center
        return copy
    }

    override func withScale(scale: Double) -> Obstacle {
        let copy = Obstacle(instance: self)
        copy.shape.scale = scale
        return copy
    }

    override func withRotation(rotation: Double) -> Obstacle {
        let copy = Obstacle(instance: self)
        copy.shape.rotation = rotation
        return copy
    }
}

extension Obstacle {
    func withRadiusOfOscillation(radiusOfOscillation: Double) -> Obstacle {
        let copy = Obstacle(instance: self)
        copy.radiusOfOscillation = radiusOfOscillation
        return copy
    }

    func withVertices(vertices: [CGPoint]) -> Obstacle {
        let copy = Obstacle(instance: self)
        guard let triangle = copy.shape as? TriangleObject else {
            fatalError("unexpected type")
        }
        let centroid = TriangleObject.getCentroid(of: vertices)
        triangle.center = centroid
        let polarVerticesRelativeToOwnCenterBeforeTransform =
            vertices.map { triangle.inverseTransform(vertex: $0) }
        triangle.polarVerticesRelativeToOwnCenterBeforeTransform =
            polarVerticesRelativeToOwnCenterBeforeTransform
        return copy
    }

}

// MARK: Persistable
extension Obstacle {
    func toPersistable() -> PersistableObstacle {
        guard let triangle = self.shape as? TriangleObject else {
            fatalError("must be a triangle")
        }

        return PersistableObstacle(shape: triangle, radiusOfOscillation: radiusOfOscillation)
    }

    static func fromPersistable(persistableObstacle: PersistableObstacle) -> Obstacle {
        Obstacle(
            shape: persistableObstacle.shape,
            radiusOfOscillation: persistableObstacle.radiusOfOscillation,
            isConcrete: true
        )
    }
}
