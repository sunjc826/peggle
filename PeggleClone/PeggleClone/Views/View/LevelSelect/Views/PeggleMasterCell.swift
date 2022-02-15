import UIKit
import Combine

protocol PeggleMasterCellDelegate: AnyObject {}

class PeggleMasterCell: UICollectionViewCell {
    @IBOutlet private var ivPicture: UIImageView!
    @IBOutlet private var lblName: UILabel!
    @IBOutlet private var lblAge: UILabel!
    @IBOutlet private var lblDescription: UILabel!
    @IBOutlet private var btnSelect: UIButton!

    weak var delegate: PeggleMasterCellDelegate?
    var viewModel: PeggleMasterCellViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    func setup() {
        setupBindings()
        registerEventHandlers()
    }
}

// MARK: Setup
extension PeggleMasterCell {
    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$name
            .assign(to: \.text, on: lblName)
            .store(in: &subscriptions)

        viewModel.$age
            .assign(to: \.text, on: lblAge)
            .store(in: &subscriptions)

        viewModel.$description
            .assign(to: \.text, on: lblDescription)
            .store(in: &subscriptions)

        viewModel.$portrait
            .assign(to: \.image, on: ivPicture)
            .store(in: &subscriptions)

        viewModel.$isSelected
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                if $0 {
                    self.btnSelect.isEnabled = false
                    self.btnSelect.setTitle("Selected", for: .normal)
                } else {
                    self.btnSelect.isEnabled = true
                    self.btnSelect.setTitle("Select", for: .normal)
                }
            }
            .store(in: &subscriptions)
    }

    private func registerEventHandlers() {
        btnSelect.addTarget(self, action: #selector(btnSelectOnTap), for: .touchUpInside)
    }
}

// MARK: Event handlers
extension PeggleMasterCell {
    @IBAction private func btnSelectOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.select()
    }
}
