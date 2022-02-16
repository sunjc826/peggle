import UIKit
import Combine

protocol PalettePegViewModelDelegate: AnyObject {
    var selectedPalettePegPublisher: AnyPublisher<Peg?, Never> { get }
    func toggleSelectInPalette(peg: Peg)
}

class PalettePegButtonViewModel: FillablePegViewModel {
    weak var delegate: PalettePegViewModelDelegate? {
        didSet {
            setupBindings()
        }
    }

    @Published var alpha: Double = Settings.Alpha.translucent.rawValue

    private var subscriptions: Set<AnyCancellable> = []

    private func setupBindings() {
        guard let delegate = delegate else {
            return
        }

        delegate.selectedPalettePegPublisher.sink { [weak self] selectedPalettePeg in
            guard let self = self else {
                return
            }
            self.alpha = selectedPalettePeg === self.peg ?
                Settings.Alpha.opaque.rawValue :
                Settings.Alpha.translucent.rawValue
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
