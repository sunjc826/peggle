import UIKit

class GameObstacleView: UIView {
    var viewModel: GameObstacleViewModel {
        didSet {
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            setNeedsDisplay()
        }
    }

    init(viewModel: GameObstacleViewModel) {
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
        drawPolygonalPath(viewModel.drawableVertices)
    }
}
