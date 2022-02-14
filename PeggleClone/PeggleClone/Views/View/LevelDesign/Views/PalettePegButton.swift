import UIKit
import Combine

/// Encapsulates a peg in the palette.
class PalettePegButton: UIButton {
    var viewModel: PalettePegViewModel
    private var subscriptions: Set<AnyCancellable> = []

    init(frame: CGRect, viewModel: PalettePegViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        addTarget(self, action: #selector(self.paletteButtonOnTap), for: .touchUpInside)
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
        drawCircleToFill(rect, withAlpha: viewModel.alpha)
    }

    private func drawPolygonalPeg(in rect: CGRect) {
        let vertices = viewModel.getDrawableVerticesToFill(rect: rect)
        drawPolygonalPath(vertices, withAlpha: viewModel.alpha)
    }

    @IBAction private func paletteButtonOnTap() {
        viewModel.toggleSelectInPalette()
    }
}
