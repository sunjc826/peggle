import UIKit

class BallView: UIView {
    var viewModel: BallViewModel {
        didSet {
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            setNeedsDisplay()
        }
    }

    init(viewModel: BallViewModel) {
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
        drawCircleToFill(rect, withAlpha: viewModel.alpha)
    }
}
