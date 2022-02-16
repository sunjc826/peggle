import UIKit
import Combine

protocol DesignerObstacleButtonDelegate: AnyObject {
    func btnDesignerObstacleOnLongPress(sender: UILongPressGestureRecognizer)
    func btnDesignerObstacleOnPan(sender: UIPanGestureRecognizer)
    func btnDesignerObstacleOnTap(sender: DesignerObstacleButton)
    func btnDesignerObstacleOnDoubleTap(sender: DesignerObstacleButton)
}

/// Encapsulates an interactive peg placed in the level designer.
class DesignerObstacleButton: UIButton {
    var viewModel: DesignerObstacleButtonViewModel {
        didSet {
            subscriptions.forEach { $0.cancel() }
            setupBindings()
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
        }
    }
    weak var delegate: DesignerObstacleButtonDelegate?

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: DesignerObstacleButtonViewModel, delegate: DesignerObstacleButtonDelegate) {
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
        drawObstacle(in: rect)
    }
}

// MARK: Setup
extension DesignerObstacleButton {
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
extension DesignerObstacleButton {
    private func configure(with drawable: ShapeDrawable) {
        drawable.setUpDrawColorConfig()
    }

    private func drawObstacle(in rect: CGRect) {
        if viewModel.isBeingEdited {
            drawSurroundingBox(in: rect)
        }

        drawPolygonalPath(
            viewModel.drawableVertices,
            withAlpha: viewModel.alpha
        )
    }
}

// MARK: Events
extension DesignerObstacleButton {
    @objc func onLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerObstacleOnLongPress(sender: sender)
    }

    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerObstacleOnPan(sender: sender)
    }

    @IBAction private func onTap(_ sender: DesignerObstacleButton) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerObstacleOnTap(sender: sender)
    }

    @IBAction private func onMultipleTap(_ sender: DesignerObstacleButton, event: UIEvent) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let touch: UITouch = event.allTouches!.first!
        if touch.tapCount == 2 {
            delegate.btnDesignerObstacleOnDoubleTap(sender: sender)
        }
    }
}
