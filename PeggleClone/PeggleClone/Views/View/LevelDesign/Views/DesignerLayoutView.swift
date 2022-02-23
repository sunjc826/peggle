import UIKit
import Combine

class DesignerLayoutView: UIView {
    var viewModel: DesignerLayoutViewModel? {
        didSet {
            setupWithViewModel()
        }
    }
    private var subscriptions: Set<AnyCancellable> = []
    var vCannonZone: UIView
    var vBucketZone: UIView

    init() {
        vCannonZone = UIView()
        vCannonZone.backgroundColor = .gray
        vCannonZone.alpha = 0.7
        vCannonZone.isHidden = true
        vBucketZone = UIView()
        vBucketZone.backgroundColor = .gray
        vBucketZone.alpha = 0.7
        vBucketZone.isHidden = true
        super.init(frame: CGRect.zero)
        addSubview(vCannonZone)
        addSubview(vBucketZone)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWithViewModel() {
        guard let viewModel = viewModel else {
            return
        }

        viewModel.displayDimensionsPublisher
            .assign(to: \.frame, on: self)
            .store(in: &subscriptions)

        viewModel.pegZonePublisher
            .sink { [weak self] pegZone in
                guard let self = self else {
                    return
                }

                self.vCannonZone.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: pegZone.width,
                    height: pegZone.minY
                )
                self.vCannonZone.isHidden = false
                self.vBucketZone.frame = CGRect(
                    x: 0,
                    y: pegZone.maxY,
                    width: pegZone.width,
                    height: self.bounds.height - pegZone.maxY
                )
                self.vBucketZone.isHidden = false
            }
            .store(in: &subscriptions)

    }
}
