import Foundation
import CoreGraphics

private let defaultAngleLimit = Double.pi / 2 - 0.1

class Cannon {
    let cannonHeight: Double = 0.05
    var angleRange: ClosedRange<Double>
    var angle: Double = 0.0
    var ejectionSpeed: Double
    var position: CGPoint
    var rotationRate: Double = 0.0
    var headPosition: CGPoint {
        position.translate(
            dx: cannonHeight * sin(angle),
            dy: cannonHeight * cos(angle)
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
        angleRange = -angleLimit...angleLimit
        self.ejectionSpeed = ejectionSpeed
    }

    func updateAngle(time dt: Double) {
        let deltaAngle = rotationRate * dt
        let newAngle = angleRange.restrictToRange(
            angle + deltaAngle
        )
        angle = newAngle
    }

    func shootBall() -> (ball: Ball, initialVelocity: CGVector) {
        (Ball(center: headPosition), ejectionVelocity)
    }
}
