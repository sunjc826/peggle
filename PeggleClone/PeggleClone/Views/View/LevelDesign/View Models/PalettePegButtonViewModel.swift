import UIKit
import Combine


protocol PalettePegViewModelDelegate: AnyObject {
    func toggleSelectInPalette(peg: Peg)
}

class PalettePegButtonViewModel: FillablePegViewModel {
    weak var delegate: PalettePegViewModelDelegate?

    @Published var isSelected = false
    @Published var alpha: Double = Settings.Alpha.translucent.rawValue

    private var subscriptions: Set<AnyCancellable> = []

    override init(peg: Peg) {
        super.init(peg: peg)
        setupBindings()
    }

    private func setupBindings() {
        $isSelected.sink { [weak self] val in
            self?.alpha = val ? Settings.Alpha.opaque.rawValue : Settings.Alpha.translucent.rawValue
        }
        .store(in: &subscriptions)
    }

    func toggleSelectInPalette() {
        delegate?.toggleSelectInPalette(peg: peg)
    }

    func setPegType(pegType: PegType) {
        peg = peg.withPegType(pegType: pegType)
    }
}
