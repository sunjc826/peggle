import UIKit
import Combine

protocol PegEntityButtonDelegate: AnyObject {
    func pegEntityButtonOnLongPress(sender: UILongPressGestureRecognizer)
    func pegEntityButtonOnPan(sender: UIPanGestureRecognizer)
    func pegEntityButtonOnTap(sender: DesignerPegButton)
    func pegEntityButtonOnDoubleTap(sender: DesignerPegButton)
}

/// Encapsulates an interactive peg placed in the level designer.
class DesignerPegButton: UIButton {
    var viewModel: DesignerPegViewModel {
        didSet {
            subscriptions.forEach { $0.cancel() }
            setupBindings()
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
        }
    }
    weak var delegate: PegEntityButtonDelegate?

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: DesignerPegViewModel, delegate: PegEntityButtonDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(frame: viewModel.displayFrame)
        center = viewModel.displayCoords
        setupBindings()
        registerEventHandlers()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configure(with: viewModel)
        drawPeg(in: rect)
    }
}

// MARK: Setup
extension DesignerPegButton {
    private func registerEventHandlers() {
        addTarget(self, action: #selector(buttonOnTap(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonOnMultipleTap(_:event:)), for: .touchDownRepeat)
        let grLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress(_:)))
        addGestureRecognizer(grLongPress)
        let grPan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(_:)))
        addGestureRecognizer(grPan)
    }

    private func setupBindings() {
        viewModel.$isBeingEdited
            .sink { [weak self] _ in
                self?.setNeedsDisplay()
            }
            .store(in: &subscriptions)
    }
}

// MARK: Drawing
extension DesignerPegButton {
    private func configure(with drawable: ShapeDrawable) {
        drawable.setUpDrawColorConfig()
    }

    private func drawPeg(in rect: CGRect) {
        if viewModel.isBeingEdited {
            drawSurroundingBox(in: rect)
        }

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
        drawPolygonalPath(
            viewModel.drawableVertices,
            withAlpha: viewModel.alpha
        )
    }
}

// MARK: Events
extension DesignerPegButton {
    @objc func onLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.pegEntityButtonOnLongPress(sender: sender)
    }

    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.pegEntityButtonOnPan(sender: sender)
    }

    @IBAction private func buttonOnTap(_ sender: DesignerPegButton) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.pegEntityButtonOnTap(sender: sender)
    }

    @IBAction private func buttonOnMultipleTap(_ sender: DesignerPegButton, event: UIEvent) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let touch: UITouch = event.allTouches!.first!
        if touch.tapCount == 2 {
            delegate.pegEntityButtonOnDoubleTap(sender: sender)
        }
    }
}
