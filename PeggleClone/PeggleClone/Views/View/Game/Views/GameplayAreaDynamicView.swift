import UIKit
import Combine

private let cannonImage = #imageLiteral(resourceName: "cannon")
private let backgroundImage = #imageLiteral(resourceName: "background")
class GameplayAreaDynamicView: UIView {
    var ivCannon: UIImageView
    var ivBackground: UIImageView
    var vCannonLine: CannonLineView

    var viewModel: GameplayAreaViewModel? {
        didSet {
            setupWithViewModel()
        }
    }
    private var subscriptions: Set<AnyCancellable> = []

    private var baseCannonTransform: CGAffineTransform?

    override init(frame: CGRect) {
        ivBackground = UIImageView(image: backgroundImage)
        ivCannon = UIImageView(image: cannonImage)
        vCannonLine = CannonLineView()
        super.init(frame: frame)
        addSubview(ivBackground)
        addSubview(ivCannon)
        addSubview(vCannonLine)
        ivBackground.frame = bounds
        ivBackground.contentMode = .scaleAspectFill
        ivCannon.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        ivCannon.center = CGPoint(x: bounds.midX, y: 0)
        vCannonLine.frame = bounds
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWithViewModel() {
        setupBindingsWithViewModel()
        setupViewsWithViewModel()
    }
}

// MARK: Setup
extension GameplayAreaDynamicView {
    private func setupViewsWithViewModel() {
        baseCannonTransform = baseCannonTransform ?? ivCannon.transform
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        vCannonLine.viewModel = viewModel.getCannonLineViewModel()
    }

    private func setupBindingsWithViewModel() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.cannonAngle
            .removeDuplicates()
            .sink { [weak self] cannonAngle in
                guard let self = self, let baseCannonTransform = self.baseCannonTransform else {
                    return
                }
                self.ivCannon.transform = baseCannonTransform.rotated(by: cannonAngle)
                self.vCannonLine.setNeedsDisplay()
            }
            .store(in: &subscriptions)

        viewModel.cannonPosition
            .removeDuplicates()
            .assign(to: \.ivCannon.center, on: self)
            .store(in: &subscriptions)

        viewModel.$displayDimensions
            .compactMap { $0 }
            .sink { [weak self] displayDimensions in
                guard let self = self, let superview = self.superview else {
                    return
                }
                self.frame = displayDimensions
                self.center.x = superview.bounds.midX
                self.ivBackground.frame = self.bounds
            }
            .store(in: &subscriptions)
    }
}
