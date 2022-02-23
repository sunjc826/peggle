import UIKit

protocol PegTypeButtonViewModelDelegate: AnyObject {
    func selectPegType(pegType: PegType)
}

class PegTypeButtonViewModel {
    weak var delegate: PegTypeButtonViewModelDelegate?

    let pegType: PegType
    let color: UIColor
    let text: String

    @Published var isSelected = false

    init(pegType: PegType) {
        self.pegType = pegType
        self.color = pegType.color
        self.text = pegType.rawValue.capitalized
    }

    func select() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.selectPegType(pegType: pegType)
    }
}
