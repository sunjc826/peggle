import UIKit
import Combine

class CannonLineView: UIView {
    var viewModel: CannonLineViewModel? {
        didSet {
            setupWithViewModel()
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let viewModel = viewModel else {
            return
        }

        guard viewModel.shouldDrawPrediction else {
            return
        }

        let positions = viewModel.predictiveLinePoints
        guard !positions.isEmpty else {
            return
        }

        let path = UIBezierPath()
        UIColor.black.setStroke()
        path.lineWidth = 3
        path.setLineDash([7, 3], count: 2, phase: 0)
        path.move(to: positions[0])
        for i in 1..<positions.count {
            path.addLine(to: positions[i])
        }
        path.stroke()
    }

    private func setupWithViewModel() {
        setupBindingsWithViewModel()
    }

    private func setupBindingsWithViewModel() {
        guard let viewModel = viewModel else {
            return
        }

        viewModel.$shouldDrawPrediction
            .sink { [weak self] _ in self?.setNeedsDisplay() }
            .store(in: &subscriptions)
    }
}
