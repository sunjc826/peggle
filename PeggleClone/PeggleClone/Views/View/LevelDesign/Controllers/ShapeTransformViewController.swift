import UIKit
import Combine

protocol ShapeTransformViewControllerDelegate: AnyObject {
    func setScale(_ scale: Double)
    func setRotation(_ rotation: Double)
}

/// Controls the transformations of the current selected peg in the designer.
class ShapeTransformViewController: UIViewController {
    @IBOutlet private var sliderScale: UISlider!
    @IBOutlet private var lblRotate: UILabel!
    @IBOutlet private var sliderRotate: UISlider!

    private var subscriptions: Set<AnyCancellable> = []
    var viewModel: ShapeTransformViewModel?
    weak var delegate: ShapeTransformViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupViews()
        registerEventHandlers()
    }
}

// MARK: Setup
extension ShapeTransformViewController {
    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$shouldShowRotate
            .sink { [weak self] shouldShowRotate in
                guard let self = self else {
                    return
                }
                self.lblRotate.isHidden = !shouldShowRotate
                self.sliderRotate.isHidden = !shouldShowRotate
            }
            .store(in: &subscriptions)

        viewModel.$scaleValue
            .sink { [weak self] scaleValue in
                self?.sliderScale.value = scaleValue
            }
            .store(in: &subscriptions)

        viewModel.$rotateValue
            .sink { [weak self] rotateValue in
                self?.sliderRotate.value = rotateValue
            }
            .store(in: &subscriptions)
    }

    private func setupViews() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        sliderScale.minimumValue = viewModel.scaleMinValue
        sliderScale.maximumValue = viewModel.scaleMaxValue
        sliderScale.value = viewModel.scaleValue
        sliderRotate.minimumValue = viewModel.rotateMinValue
        sliderRotate.maximumValue = viewModel.rotateMaxValue
        sliderRotate.value = viewModel.rotateValue
    }

    private func registerEventHandlers() {
        sliderScale.addTarget(self, action: #selector(onSliderScaleChanged(sender:)), for: .valueChanged)
        sliderRotate.addTarget(self, action: #selector(onSliderRotateChanged(sender:)), for: .valueChanged)
    }
}

// MARK: Event handlers
extension ShapeTransformViewController {
    @IBAction private func onSliderScaleChanged(sender: UISlider) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.setScale(Double(sender.value))
    }

    @IBAction private func onSliderRotateChanged(sender: UISlider) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.setRotation(Double(sender.value))
    }
}
