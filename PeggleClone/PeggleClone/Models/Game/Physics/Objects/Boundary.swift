import Foundation
import CoreGraphics

/// Represents the "world" of all physics objects.
class Boundary: Rectangle {
    var halfWidth: Double

    var halfHeight: Double

    var scale: Double = 1

    var rotation: Double = 0

    var center: CGPoint

    init(center: CGPoint, halfWidth: Double, halfHeight: Double) {
        self.center = center
        self.halfWidth = halfWidth
        self.halfHeight = halfHeight
    }

    convenience init(center: CGPoint, width: Double, height: Double) {
        self.init(
            center: center,
            halfWidth: width / 2,
            halfHeight: height / 2
        )
    }

    convenience init(topLeft: CGPoint, width: Double, height: Double) {
        let center = topLeft.translate(offset: CGVector(dx: width / 2, dy: height / 2))
        self.init(center: center, width: width, height: height)
    }

    convenience init(playArea: PlayArea) {
        self.init(center: playArea.center, width: playArea.width, height: playArea.height)
    }
}
