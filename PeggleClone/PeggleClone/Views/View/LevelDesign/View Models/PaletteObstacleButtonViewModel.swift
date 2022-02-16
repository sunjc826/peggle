import UIKit
import Combine

protocol PaletteObstacleButtonViewModelDelegate: AnyObject {
    var isObstacleSelectedPublisher: AnyPublisher<Bool, Never> { get }
    func toggleSelectObstacleInPalette()
}
class PaletteObstacleButtonViewModel: FillableObstacleViewModel {
    weak var delegate: PaletteObstacleButtonViewModelDelegate? {
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

        delegate.isObstacleSelectedPublisher.sink { [weak self] val in
            guard let self = self else {
                return
            }

            self.alpha = val ? Settings.Alpha.opaque.rawValue : Settings.Alpha.translucent.rawValue
        }
        .store(in: &subscriptions)
    }

    func toggleSelectInPalette() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.toggleSelectObstacleInPalette()
    }
}
