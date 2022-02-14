import UIKit

private let interiorColor = UIColor.lightGray
private let ballBorderColor = UIColor.black

protocol BallViewModelDelegate: AnyObject, CoordinateMappable {}

class BallViewModel: ShapeDrawable {
    weak var delegate: BallViewModelDelegate?
    var ball: Ball

    var displayCoords: CGPoint {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return delegate.getDisplayCoords(of: ball.boundingBox.center)
    }

    var displayFrame: CGRect {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return CGRect(
            x: 0,
            y: 0,
            width: delegate.getDisplayLength(of: ball.boundingBox.width),
            height: delegate.getDisplayLength(of: ball.boundingBox.height)
        )
    }

    var fillColor: UIColor {
        interiorColor
    }

    var borderColor: UIColor {
        ballBorderColor
    }

    var alpha: Double {
        1.0
    }

    init(ball: Ball) {
        self.ball = ball
    }
}
