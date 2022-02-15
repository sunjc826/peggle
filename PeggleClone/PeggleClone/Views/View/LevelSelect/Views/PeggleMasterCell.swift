import UIKit
import Combine

protocol PeggleMasterCellDelegate: AnyObject {}

class PeggleMasterCell: UICollectionViewCell {
    @IBOutlet private var ivPicture: UIImageView!
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
            .assign(to: \.text, on: lblDescription)
            .store(in: &subscriptions)
        
        viewModel.$portrait
            .assign(to: \.image, on: ivPicture)
            .store(in: &subscriptions)
    }
    
    private func registerEventHandlers() {
        btnSelect.addTarget(self, action: #selector(btnSelectOnTap), for: .touchUpInside)
    }
}

// MARK: Event handlers
extension PeggleMasterCell {
    @IBAction private func btnSelectOnTap() {
        
    }
}
