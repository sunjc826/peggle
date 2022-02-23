import UIKit
import Combine

private let cannonImage = #imageLiteral(resourceName: "cannon")
private let backgroundImage = #imageLiteral(resourceName: "background")
private let bucketImage = #imageLiteral(resourceName: "bucket")

// reference: https://stackoverflow.com/questions/28980146/caemittercell-without-using-an-image
private func getShape() -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 5, height: 5)

    let path = CGPath(ellipseIn: rect, transform: nil)

    return UIGraphicsImageRenderer(size: rect.size).image { context in
        context.cgContext.setFillColor(UIColor.white.cgColor)
        context.cgContext.addPath(path)
        context.cgContext.fillPath()
    }
}

class GameplayAreaDynamicView: UIView {
    var ivCannon: UIImageView
    var ivBackground: UIImageView
    var vCannonLine: CannonLineView
    var ivBucket: BucketView

    var particle: UIImage
    var emitterLayer = CAEmitterLayer()
    var emitterCell = CAEmitterCell()

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
        ivBucket = BucketView(image: bucketImage)
        particle = getShape()
        super.init(frame: frame)
        addSubview(ivBackground)
        addSubview(ivCannon)
        addSubview(vCannonLine)
        addSubview(ivBucket)
        ivBackground.frame = bounds
        ivBackground.contentMode = .scaleAspectFill
        ivCannon.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        ivCannon.center = CGPoint(x: bounds.midX, y: 0)
        vCannonLine.frame = bounds
        backgroundColor = UIColor.clear
        setupEmitterCell()
        setupEmitterLayer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWithViewModel() {
        setupBindingsWithViewModel()
        setupViewsWithViewModel()
    }

    // reference: https://www.raywenderlich.com/10317653-calayer-tutorial-for-ios-getting-started
    func setupEmitterLayer() {
        emitterLayer.frame = bounds

        layer.addSublayer(emitterLayer)
        emitterLayer.seed = UInt32(Date().timeIntervalSince1970)
        emitterLayer.renderMode = .additive
        emitterLayer.emitterCells = [emitterCell]
        emitterLayer.lifetime = 0
    }

    func setupEmitterCell() {

        emitterCell.contents = particle.cgImage

        emitterCell.velocity = 50.0
        emitterCell.velocityRange = 10.0

        emitterCell.color = UIColor.lightGray.cgColor

        emitterCell.emissionLatitude = 0
        emitterCell.emissionLongitude = 0
        emitterCell.emissionRange = 0

        emitterCell.lifetime = 1.0
        emitterCell.birthRate = 2.0
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
        ivBucket.viewModel = viewModel.getBucketViewModel()
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

extension GameplayAreaDynamicView: BallViewDelegate {
    func renderParticle(with data: CollisionParticleData) {
        emitterLayer.emitterPosition = data.collisionLocation
        emitterLayer.lifetime = 1.5
        let vector = data.collisionDirection
        emitterCell.emissionLongitude = -atan2(vector.dy, vector.dx)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.emitterLayer.lifetime = 0.0
        }
    }
}
