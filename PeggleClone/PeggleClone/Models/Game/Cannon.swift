import Foundation
import CoreGraphics

// Convention: Rotation clockwise is positive

private let defaultAngleLimit = Double.pi / 2 - 0.1

class Cannon {
    var cannonBarrelLength: Double = Settings.Cannon.height
    var angleLimit: Double
    var angleRange: ClosedRange<Double>
    @Published var angle: Double = 0.0
    var ejectionSpeed: Double
    @Published var position: CGPoint
    var targetAngle: Double?

    var headPosition: CGPoint {
        position.translate(
            dx: cannonBarrelLength * sin(-angle),
            dy: cannonBarrelLength * cos(angle)
        )
    }
    var ejectionVelocity: CGVector {
        CGVector(from: position, to: headPosition).scaleTo(length: ejectionSpeed)
    }

    init(
        position: CGPoint,
        angleLimit: Double = defaultAngleLimit,
        ejectionSpeed: Double = Settings.Cannon.defaultEjectionSpeed
    ) {
        assert(angleLimit > 0)
        self.position = position
        self.angleLimit = angleLimit
        angleRange = -angleLimit...angleLimit
        self.ejectionSpeed = ejectionSpeed
    }

    func updateAngle() {
        guard let targetAngle = targetAngle else {
            return
        }

        let newAngle = angleRange.restrictToRange(
            targetAngle
        )

        angle = newAngle
        self.targetAngle = nil
    }

    func shootBall() -> (ball: Ball, initialVelocity: CGVector) {
        (Ball(center: headPosition), ejectionVelocity)
    }
}
