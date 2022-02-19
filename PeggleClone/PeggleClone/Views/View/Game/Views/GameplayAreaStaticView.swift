import UIKit

class GameplayAreaStaticView: UIView {
    var svInfo: UIStackView
    var viewModel: GameplayAreaViewModel? {
        didSet {
            setupWithViewModel()
        }
    }

    init() {
        svInfo = UIStackView()
        super.init(frame: CGRect.zero)
        addSubview(svInfo)
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWithViewModel() {
        setupViewsWithViewModel()
    }

    func setupConstraints() {
        let constraints = [
            svInfo.topAnchor.constraint(equalTo: self.topAnchor, constant: 30.0),
            svInfo.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 30.0),
            svInfo.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            svInfo.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            svInfo.heightAnchor.constraint(equalTo: superview!.heightAnchor, multiplier: 0.2)
        ]
        constraints.forEach { $0.isActive = true }
    }

    private func setupViewsWithViewModel() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        svInfo.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let vmBalls = GenericStatViewModel(key: "Balls", value: viewModel.ballsLeftPublisher)
        let svBalls = GenericStatView(viewModel: vmBalls)

        svInfo.addArrangedSubview(svBalls)

        let vmScore = GenericStatViewModel(key: "Score", value: viewModel.totalScorePublisher)
        let svScore = GenericStatView(viewModel: vmScore)

        svInfo.addArrangedSubview(svScore)

        for pegStatViewModel in viewModel.pegStatViewModels {
            let svPegStat = PegStatView(viewModel: pegStatViewModel)
            svInfo.addArrangedSubview(svPegStat)
        }
    }
}
