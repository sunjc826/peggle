import UIKit

/// Encapsulates a peg in a stack view.
class StackPegView: UIView {
    var viewModel: StackPegViewModel

    init(viewModel: StackPegViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
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
        drawPalettePeg(in: rect)
    }

    private func drawPalettePeg(in rect: CGRect) {
        if viewModel.shouldDrawCircle {
            drawCircularPeg(in: rect)
        } else if viewModel.shouldDrawPolygon {
            drawPolygonalPeg(in: rect)
        } else {
            logger.error("nothing to draw")
        }
    }

    private func drawCircularPeg(in rect: CGRect) {
        drawCircleToFill(rect)
    }

    private func drawPolygonalPeg(in rect: CGRect) {
        let vertices = viewModel.getDrawableVerticesToFill(rect: rect)
        drawPolygonalPath(vertices)
    }
}
