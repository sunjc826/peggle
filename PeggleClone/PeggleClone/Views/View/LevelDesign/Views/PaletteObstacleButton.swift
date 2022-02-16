import UIKit
import Combine

/// Encapsulates a peg in the palette.
class PaletteObstacleButton: UIButton {
    var viewModel: PaletteObstacleButtonViewModel
    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: PaletteObstacleButtonViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        addTarget(self, action: #selector(self.onTap), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBindings() {
        viewModel.$alpha
            .sink { [weak self] _ in
                self?.setNeedsDisplay()
            }
            .store(in: &subscriptions)
    }

    func configure(with drawable: ShapeDrawable) {
        drawable.setUpDrawColorConfig()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configure(with: viewModel)
        drawPaletteObstacle(in: rect)
    }

    private func drawPaletteObstacle(in rect: CGRect) {
        let vertices = viewModel.getDrawableVerticesToFill(rect: rect)
        drawPolygonalPath(vertices, withAlpha: viewModel.alpha)
    }

    @IBAction private func onTap() {
        viewModel.toggleSelectInPalette()
    }
}
