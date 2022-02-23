import UIKit

protocol DesignerScrollViewDelegate: AnyObject {
    func scrollvDesignerOnPan(dy: Double)
    func scrollvDesignerEndPan()
}

class DesignerScrollView: UIScrollView {
    weak var ownDelegate: DesignerScrollViewDelegate?
    var vLayout: DesignerLayoutView

    override init(frame: CGRect) {
        vLayout = DesignerLayoutView()
        super.init(frame: frame)
        isScrollEnabled = false

        vLayout.frame = bounds
        addSubview(vLayout)
        registerEventHandlers()
    }

    private func registerEventHandlers() {
        let grPan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(grPan)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let ownDelegate = ownDelegate else {
            fatalError("should not be nil")
        }

        let reversedTranslation = CGVector.fromPoint(point: sender.translation(in: self)).reverse()
        sender.setTranslation(CGPoint.zero, in: self)

        switch sender.state {
        case .began, .changed:
            ownDelegate.scrollvDesignerOnPan(dy: reversedTranslation.dy)
        case .ended:
            ownDelegate.scrollvDesignerEndPan()
        default:
            break
        }
    }
}
