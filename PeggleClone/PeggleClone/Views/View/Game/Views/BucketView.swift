import UIKit
import Combine

class BucketView: UIImageView {
    var viewModel: BucketViewModel? {
        didSet {
            setupWithViewModel()
            isHidden = false
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    override init(image: UIImage?) {
        super.init(image: image)
        isHidden = true
        contentMode = .scaleToFill
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSurroundingBox(in: rect)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWithViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.displayFramePublisher
            .assign(to: \.frame, on: self)
            .store(in: &subscriptions)
        viewModel.displayCoordsPublisher
            .assign(to: \.center, on: self)
            .store(in: &subscriptions)
    }
}
