import UIKit
import Combine

private let opaqueAlpha = 1.0
private let translucentAlpha = 0.5

protocol PalettePegViewModelDelegate: AnyObject {
    func toggleSelectInPalette(peg: Peg)
}

class PalettePegViewModel: FillablePegViewModel {
    weak var delegate: PalettePegViewModelDelegate?

    @Published var isSelected = false
    @Published var alpha: Double = translucentAlpha

    private var subscriptions: Set<AnyCancellable> = []

    override init(peg: Peg) {
        super.init(peg: peg)
        setupBindings()
    }

    private func setupBindings() {
        $isSelected.sink { [weak self] val in
            self?.alpha = val ? opaqueAlpha : translucentAlpha
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
