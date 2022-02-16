import UIKit
import Combine

protocol PaletteObstacleButtonViewModelDelegate: AnyObject {
    func toggleSelectObstacleInPalette()
}
class PaletteObstacleButtonViewModel: FillableObstacleViewModel {
    weak var delegate: PaletteObstacleButtonViewModelDelegate?
    
    @Published var isSelected = false
    @Published var alpha: Double = Settings.Alpha.translucent.rawValue

    private var subscriptions: Set<AnyCancellable> = []

    override init() {
        super.init()
        setupBindings()
    }

    private func setupBindings() {
        $isSelected.sink { [weak self] val in
            self?.alpha = val ? Settings.Alpha.opaque.rawValue : Settings.Alpha.translucent.rawValue
        }
        .store(in: &subscriptions)
    }

    func toggleSelectInPalette() {
        delegate?.toggleSelectObstacleInPalette()
    }
}
