import UIKit
import Combine

/// Encapsulates a peg in the palette.
class PaletteObstacleButton: UIButton {
    var viewModel: PaletteObstacleButtonViewModel? {
        didSet {
            setup()
        }
    }
    private var subscriptions: Set<AnyCancellable> = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
    }

    func setup() {
        setupBindings()
        setupEventHandlers()
        setNeedsDisplay()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$alpha
            .sink { [weak self] _ in
                self?.setNeedsDisplay()
            }
            .store(in: &subscriptions)
    }

    private func setupEventHandlers() {
        addTarget(self, action: #selector(self.onTap), for: .touchUpInside)
    }

    func configure(with drawable: ShapeDrawable) {
        drawable.setUpDrawColorConfig()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let viewModel = viewModel else {
            return
        }

        configure(with: viewModel)
        drawPaletteObstacle(in: rect)
    }

    private func drawPaletteObstacle(in rect: CGRect) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let vertices = viewModel.getDrawableVerticesToFill(rect: rect)
        drawPolygonalPath(vertices, withAlpha: viewModel.alpha)
    }

    @IBAction private func onTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.toggleSelectInPalette()
    }
}
