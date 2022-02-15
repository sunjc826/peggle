import Foundation
import CoreGraphics

private let defaultBallRadius = 0.01

class Ball: GameEntity, Circle, Equatable, Hashable {
    weak var rigidBody: RigidBodyObject?

    var isDestructible = false

    var isOverlayable = false

    var radiusBeforeTransform: Double

    var scale: Double = 1.0

    var rotation: Double = 0.0

    var center: CGPoint

    static func == (lhs: Ball, rhs: Ball) -> Bool {
        lhs === rhs
    }

    init(
        center: CGPoint,
        radiusBeforeTransform: Double = defaultBallRadius
    ) {
        self.center = center
        self.radiusBeforeTransform = radiusBeforeTransform
    }

    convenience init(instance: Ball) {
        self.init(
            center: instance.center,
            radiusBeforeTransform: instance.radiusBeforeTransform
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(center)
    }

    func withCenter(center: CGPoint) -> Ball {
        let copy = Ball(instance: self)
        copy.center = center
        return copy
    }

    func withScale(scale: Double) -> Ball {
        let copy = Ball(instance: self)
        copy.scale = scale
        return copy
    }

    func withRotation(rotation: Double) -> Ball {
        let copy = Ball(instance: self)
        copy.rotation = rotation
        return copy
    }
}
