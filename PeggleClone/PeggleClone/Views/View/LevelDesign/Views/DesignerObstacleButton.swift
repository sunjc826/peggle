import UIKit
import Combine

protocol DesignerObstacleButtonDelegate: AnyObject {
    func btnDesignerObstacleOnLongPress(sender: UILongPressGestureRecognizer)
    func btnDesignerObstacleOnPan(sender: UIPanGestureRecognizer)
    func btnDesignerObstacleOnTap(sender: DesignerObstacleButton)
    func btnDesignerObstacleOnDoubleTap(sender: DesignerObstacleButton)
    func btnDesignerObstacleVertexOnPan(
        sender: UIPanGestureRecognizer,
        vmDesignerObstacleButton: DesignerObstacleButtonViewModel,
        vertexIndex: Int
    )
}

/// Encapsulates an interactive peg placed in the level designer.
class DesignerObstacleButton: UIButton {
    var viewModel: DesignerObstacleButtonViewModel {
        didSet {
            subscriptions.forEach { $0.cancel() }
            setupBindings()
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            setNeedsDisplay()
        }
    }
    weak var delegate: DesignerObstacleButtonDelegate?
    var btnsForVertices: [VertexButton] = []

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
            .removeDuplicates()
            .sink { [weak self] isBeingEdited in
                guard let self = self else {
                    return
                }

                self.handleEdit(isBeingEdited: isBeingEdited)
                self.setNeedsDisplay()
            }
            .store(in: &subscriptions)
    }
}

extension DesignerObstacleButton {
    private func handleEdit(isBeingEdited: Bool) {
        if isBeingEdited {
            let triangleVertices = viewModel.vertices
            triangleVertices.enumerated().forEach { index, vertex in
                let btnVertex = VertexButton(vertex: vertex, vertexIndex: index)
                btnVertex.delegate = self
                btnsForVertices.append(btnVertex)
                superview?.addSubview(btnVertex)
            }
        } else {
            btnsForVertices.forEach { $0.removeFromSuperview() }
            btnsForVertices.removeAll()
        }
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

extension DesignerObstacleButton: VertexButtonDelegate {
    func btnVertexOnPan(sender: UIPanGestureRecognizer, vertexIndex: Int) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerObstacleVertexOnPan(
            sender: sender,
            vmDesignerObstacleButton: viewModel,
            vertexIndex: vertexIndex
        )
    }
}
