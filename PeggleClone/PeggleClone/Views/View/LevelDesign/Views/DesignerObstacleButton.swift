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
    func btnDesignerObstacleOscillationLocalityOnPan(
        vmDesignerObstacleButton: DesignerObstacleButtonViewModel,
        radius: Double
    )
}

/// Encapsulates an interactive peg placed in the level designer.
class DesignerObstacleButton: UIButton {

    // Remarks: While didSet is still reactive programming to some extent, I wonder how this can
    // be made more reactive. The main problem is that on updates to the underlying model, the entire
    // viewModel is replaced, which would cause any sub-view models to be outdated as well, if any. For
    // e.g. if they delegate to an older viewModel, the reference would become stale.
    // This means Combine's observer style of "pulling" information from publishers rather than pushing
    // changes is not so easy to do here. I wonder how this can be rectified. Or maybe this isn't
    // a real problem at all and is just a consequence of my design choices.
    // OR MAYBE: something like a hydrate method for a viewModel, this way the viewModel stays intact.
    var viewModel: DesignerObstacleButtonViewModel {
        didSet {
            subscriptions.forEach { $0.cancel() }
            setupBindings()
            frame = viewModel.displayFrame
            center = viewModel.displayCoords
            // Remarks: I have to explicitly "push" changes to the subviews like buttons,
            // instead of having them observe something.
            // Perhaps, they can observe the DesignerObstacleButtonViewModel, but is this really such a
            // good idea?
            // Furthermore, how would an implementation in which the subviews have their own view models
            // look like? It seems I just cannot avoid "push"ing changes to subviews. For e.g. I still
            // have to explicitly set the new view models for the subviews.
            updateButtons()
            setNeedsDisplay()
        }
    }
    weak var delegate: DesignerObstacleButtonDelegate?
    var btnsForVertices: [VertexButton] = []
    var btnOscillationLocality: OscillationLocalityButton?

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
    func setupAfterAddingToSuperview() {
        setupButtons()
    }

    private func setupButtons() {
        setupOscillationLocalityButton()
        superview?.bringSubviewToFront(self)
        setupVertexButtons()
    }

    private func setupVertexButtons() {
        let triangleVertices = viewModel.vertices
        triangleVertices.enumerated().forEach { index, vertex in
            let btnVertex = VertexButton(vertex: vertex, vertexIndex: index)
            btnVertex.delegate = self
            btnVertex.isHidden = true
            btnsForVertices.append(btnVertex)
            superview?.addSubview(btnVertex)
        }
    }

    private func setupOscillationLocalityButton() {
        btnOscillationLocality = OscillationLocalityButton(
            center: viewModel.displayCoords,
            radius: viewModel.displayRadiusOfOscillation
        )

        guard let btnOscillationLocality = btnOscillationLocality else {
            fatalError("should not be nil")
        }
        btnOscillationLocality.delegate = self
        btnOscillationLocality.isHidden = true
        superview?.addSubview(btnOscillationLocality)
    }

    private func updateButtons() {
        updateVertexButtons()
        updateOscillationLocalityButton()
    }

    private func updateVertexButtons() {
        let triangleVertices = viewModel.vertices
        triangleVertices.enumerated().forEach { index, vertex in
            let btnVertex = btnsForVertices[index]
            btnVertex.center = vertex
        }
    }

    private func updateOscillationLocalityButton() {
        // Remark: Alternatively, it is more MVVM to pass a compound object and configure the
        // button with these 2 pieces of information.
        btnOscillationLocality?.center = viewModel.displayCoords
        btnOscillationLocality?.radius = viewModel.displayRadiusOfOscillation
    }

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
            btnsForVertices.forEach { $0.isHidden = false }
            btnOscillationLocality?.isHidden = false
        } else {
            btnsForVertices.forEach { $0.isHidden = true }
            btnOscillationLocality?.isHidden = true
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

extension DesignerObstacleButton: OscillationLocalityButtonDelegate {
    func btnOscillationLocalityOnPan(radius: Double) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnDesignerObstacleOscillationLocalityOnPan(
            vmDesignerObstacleButton: viewModel,
            radius: radius
        )
    }
}
