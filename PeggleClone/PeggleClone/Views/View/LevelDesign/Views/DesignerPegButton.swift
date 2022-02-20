import UIKit
import Combine

protocol DesignerPegButtonDelegate: AnyObject {
    func btnDesignerPegOnLongPress(sender: UILongPressGestureRecognizer)
    func btnDesignerPegOnPan(sender: UIPanGestureRecognizer)
    func btnDesignerPegOnTap(sender: DesignerPegButton)
    func btnDesignerPegOnDoubleTap(sender: DesignerPegButton)
}

/// Encapsulates an interactive peg placed in the level designer.
class DesignerPegButton: UIButton {
    var viewModel: DesignerPegButtonViewModel {
        didSet {
            subscriptions.forEach { $0.cancel() }
            setupBindings()
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            setNeedsDisplay()
        }
    }
    weak var delegate: DesignerPegButtonDelegate?

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: DesignerPegButtonViewModel, delegate: DesignerPegButtonDelegate) {
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
        addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(onMultipleTap(_:event:)), for: .touchDownRepeat)
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
            globalLogger.error("nothing to draw")
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

        delegate.btnDesignerPegOnLongPress(sender: sender)
    }

    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerPegOnPan(sender: sender)
    }

    @IBAction private func onTap(_ sender: DesignerPegButton) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerPegOnTap(sender: sender)
    }

    @IBAction private func onMultipleTap(_ sender: DesignerPegButton, event: UIEvent) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let touch: UITouch = event.allTouches!.first!
        if touch.tapCount == 2 {
            delegate.btnDesignerPegOnDoubleTap(sender: sender)
        }
    }
}
