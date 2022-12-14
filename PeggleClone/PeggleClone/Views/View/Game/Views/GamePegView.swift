import UIKit

class GamePegView: UIView {
    var viewModel: GamePegViewModel {
        didSet {
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            setNeedsDisplay()
        }
    }

    init(viewModel: GamePegViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.displayFrame)
        center = viewModel.displayCoords
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with drawable: ShapeDrawable) {
        drawable.setUpDrawColorConfig()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configure(with: viewModel)
        if viewModel.shouldDrawCircle {
            drawCircularPeg(in: rect)
        } else if viewModel.shouldDrawPolygon {
            drawPolygonalPeg(in: rect)
        } else {
            globalLogger.error("nothing to draw")
        }
    }

    private func drawCircularPeg(in rect: CGRect) {
        drawPath(getCircularPathToFill(rect))
    }

    private func drawPolygonalPeg(in rect: CGRect) {
        drawPath(getPolygonalPath(viewModel.drawableVertices))
    }

    private func drawPath(_ path: UIBezierPath) {
        path.fill(with: .normal, alpha: viewModel.alpha)
        path.stroke(with: .normal, alpha: viewModel.alpha)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        if viewModel.shouldLightUp {
            drawGradient(path: path, gradient: Settings.Peg.Color.gradient, context: context)
        }
    }
}
