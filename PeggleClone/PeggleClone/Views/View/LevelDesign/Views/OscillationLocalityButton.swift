import UIKit

protocol OscillationLocalityButtonDelegate: AnyObject {
    func btnOscillationLocalityOnPan(radius: Double)
}

private let panThreshold = 5.0

class OscillationLocalityButton: UIView {
    weak var delegate: OscillationLocalityButtonDelegate?
    var radius: Double {
        didSet {
            let frame = CGRect(
                rectangle: RectangleObject(
                    center: center, halfWidth: radius, halfHeight: radius
                )
            )
            self.frame = frame
            layer.cornerRadius = 0.5 * bounds.size.width
            clipsToBounds = true
        }
    }

    init(center: CGPoint, radius: Double) {
        self.radius = radius
        let frame = CGRect(
            rectangle: RectangleObject(
                center: center, halfWidth: radius, halfHeight: radius
            )
        )
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
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

    @objc private func onPan(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else {
            return
        }

        let panRadius = sender.location(in: superview).distanceTo(point: center)

        switch sender.state {
        case .began:
            guard panRadius >= radius - panThreshold else {
                return
            }
        default:
            break
        }

        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.btnOscillationLocalityOnPan(radius: panRadius)
    }

}
