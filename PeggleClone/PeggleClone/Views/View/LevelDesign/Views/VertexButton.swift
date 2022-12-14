import UIKit

private var radiusInPixels: Double = 10

protocol VertexButtonDelegate: AnyObject {
    func btnVertexOnPan(sender: UIPanGestureRecognizer, vertexIndex: Int)
}

class VertexButton: UIView {
    weak var delegate: VertexButtonDelegate?
    var vertexIndex: Int
    init(vertex: CGPoint, vertexIndex: Int) {
        self.vertexIndex = vertexIndex
        let frame = CGRect(
            rectangle: RectangleObject(
                center: vertex, halfWidth: radiusInPixels, halfHeight: radiusInPixels
            )
        )
        super.init(frame: frame)

        // reference: https://stackoverflow.com/questions/26050655/how-to-create-a-circular-button-in-swift

        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
        registerEventHandlers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func registerEventHandlers() {
        let grPan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(_:)))
        addGestureRecognizer(grPan)
    }

    override func draw(_ rect: CGRect) {
        drawCircleToFill(rect)
    }

    @objc private func onPan(_ sender: UIPanGestureRecognizer) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnVertexOnPan(sender: sender, vertexIndex: vertexIndex)
    }
}
