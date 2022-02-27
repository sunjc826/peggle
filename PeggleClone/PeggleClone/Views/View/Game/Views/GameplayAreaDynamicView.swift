import UIKit
import Combine

private let cannonImage = #imageLiteral(resourceName: "cannon")
// XCode is bugging out, so I cannot even select the image literal for this image.
// swiftlint:disable object_literal
private let cannonShootingImage = UIImage(named: "cannon_shooting")
// swiftlint:enable object_literal
private let backgroundImage = #imageLiteral(resourceName: "background")
private let bucketImage = #imageLiteral(resourceName: "bucket")

private let explosionParticleDirectionCount: Int = 10

// reference: https://stackoverflow.com/questions/28980146/caemittercell-without-using-an-image
private func getParticle() -> UIImage {
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

    var collisionParticle: UIImage
    var explosionParticle: UIImage
    var elCollision = CAEmitterLayer()
    var ecCollision = CAEmitterCell()
    var elExplosion = CAEmitterLayer()
    var ecExplosions: [CAEmitterCell] = []

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
        collisionParticle = getParticle()
        explosionParticle = getParticle()
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
        elCollision.frame = bounds
        layer.addSublayer(elCollision)
        elCollision.seed = UInt32(Date().timeIntervalSince1970)
        elCollision.renderMode = .additive
        elCollision.emitterCells = [ecCollision]
        elCollision.lifetime = 0

        elExplosion.frame = bounds
        layer.addSublayer(elExplosion)
        elExplosion.seed = UInt32(Date().timeIntervalSince1970)
        elExplosion.renderMode = .additive
        elExplosion.emitterCells = ecExplosions
        elExplosion.lifetime = 0
    }

    func setupEmitterCell() {
        ecCollision.contents = collisionParticle.cgImage

        ecCollision.velocity = 75.0
        ecCollision.velocityRange = 10.0

        ecCollision.color = UIColor.lightGray.cgColor

        ecCollision.emissionLatitude = 0
        ecCollision.emissionLongitude = 0
        ecCollision.emissionRange = Double.pi / 6

        ecCollision.lifetime = 1.0
        ecCollision.birthRate = 2.5

        for i in 0..<explosionParticleDirectionCount {
            let ecExplosion = CAEmitterCell()
            ecExplosion.contents = explosionParticle.cgImage
            ecExplosion.velocity = 250.0
            ecExplosion.velocityRange = 0.0

            ecExplosion.color = UIColor.green.cgColor

            ecExplosion.emissionLatitude = 0
            ecExplosion.emissionLongitude = 2 * Double.pi /
                Double(explosionParticleDirectionCount) *
                Double(i)
            ecExplosion.emissionRange = 0
            ecExplosion.lifetime = 1.5
            ecExplosion.birthRate = 1.0
            ecExplosions.append(ecExplosion)
        }
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

        viewModel.cannonAnglePublisher
            .removeDuplicates()
            .sink { [weak self] cannonAngle in
                guard let self = self, let baseCannonTransform = self.baseCannonTransform else {
                    return
                }
                self.ivCannon.transform = baseCannonTransform.rotated(by: cannonAngle)
                self.vCannonLine.setNeedsDisplay()
            }
            .store(in: &subscriptions)

        viewModel.cannonPositionPublisher
            .removeDuplicates()
            .assign(to: \.center, on: ivCannon)
            .store(in: &subscriptions)

        viewModel.cannonIsShootingPublisher
            .removeDuplicates()
            .sink { [weak self] isShooting in
                guard isShooting else {
                    return
                }
                self?.ivCannon.image = cannonShootingImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.ivCannon.image = cannonImage
                }
            }
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
                self.elCollision.frame = self.bounds
                self.elExplosion.frame = self.bounds
            }
            .store(in: &subscriptions)

        viewModel.explosionEffectAtLocationPublisher
            .sink { [weak self] explosionData in
                self?.renderExplosion(with: explosionData)
            }
            .store(in: &subscriptions)
    }

    func renderExplosion(with data: ExplosionParticleData) {
        elExplosion.emitterPosition = data.explosionPoint
        elExplosion.lifetime = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.elExplosion.lifetime = 0.0
        }
    }
}

extension GameplayAreaDynamicView: BallViewDelegate {
    func renderParticle(with data: CollisionParticleData) {
        elCollision.emitterPosition = data.collisionLocation
        elCollision.lifetime = 1.0
        let vector = data.collisionDirection
        ecCollision.emissionLongitude = -atan2(vector.dy, vector.dx)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.elCollision.lifetime = 0.0
        }
    }
}
