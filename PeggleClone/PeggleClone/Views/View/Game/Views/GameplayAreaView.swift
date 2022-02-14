import UIKit
import Combine

class GameplayAreaView: UIView {
    @IBOutlet private var ivCannon: UIImageView!
    @IBOutlet private var svInfo: UIStackView!

    var viewModel: GameplayAreaViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    private var baseCannonTransform: CGAffineTransform?

    func setup(viewModel: GameplayAreaViewModel) {
        self.viewModel = viewModel
        setupViews()
        setupBindings()
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
}

// MARK: Setup
extension GameplayAreaView {
    private func setupViews() {
        baseCannonTransform = ivCannon.transform

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        guard let ballsLeft = viewModel.ballsLeft else {
            fatalError("should not be nil")
        }

        let vmBalls = GenericStatViewModel(key: "Balls", value: ballsLeft)
        let svBalls = GenericStatView(viewModel: vmBalls)

        svInfo.addArrangedSubview(svBalls)

        guard let score = viewModel.score else {
            fatalError("should not be nil")
        }

        let vmScore = GenericStatViewModel(key: "Score", value: score)
        let svScore = GenericStatView(viewModel: vmScore)

        svInfo.addArrangedSubview(svScore)

        for pegStatViewModel in viewModel.pegStatViewModels {
            let svPegStat = PegStatView(viewModel: pegStatViewModel)
            svInfo.addArrangedSubview(svPegStat)
        }
    }

    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        guard let cannonAngle = viewModel.cannonAngle else {
            fatalError("should not be nil")
        }

        cannonAngle
            .removeDuplicates()
            .sink { [weak self] cannonAngle in
                guard let self = self, let baseCannonTransform = self.baseCannonTransform else {
                    return
                }

                self.ivCannon.transform = baseCannonTransform.rotated(by: cannonAngle)
            }
            .store(in: &subscriptions)

        guard let cannonPosition = viewModel.cannonPosition else {
            fatalError("should not be nil")
        }

        cannonPosition
            .removeDuplicates()
            .assign(to: \.ivCannon.center, on: self)
            .store(in: &subscriptions)
    }
}
