import UIKit
import Combine

protocol PeggleMasterCellViewModelDelegate: AnyObject {
    var selectedPeggleMasterPublisher: AnyPublisher<PeggleMaster?, Never> { get }
    func selectPeggleMaster(peggleMaster: PeggleMaster)
}

class PeggleMasterCellViewModel {
    weak var delegate: PeggleMasterCellViewModelDelegate? {
        didSet {
            delegate?.selectedPeggleMasterPublisher
                .sink { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.isSelected = $0?.id == self.peggleMaster.id
                }
                .store(in: &subscriptions)
        }
    }
    private var subscriptions: Set<AnyCancellable> = []
    @Published private(set) var name: String?
    @Published private(set) var age: String?
    @Published private(set) var description: String?
    @Published private(set) var portrait: UIImage?
    @Published private(set) var isSelected = false

    private let peggleMaster: PeggleMaster

    init(peggleMaster: PeggleMaster) {
        self.peggleMaster = peggleMaster
        self.name = "\(peggleMaster.name) \(peggleMaster.title)"
        self.age = String(peggleMaster.age)
        self.description = peggleMaster.description
        DispatchQueue.global().async {
            let image = UIImage(named: peggleMaster.id)
            DispatchQueue.main.async {
                self.portrait = image
            }
        }
    }

    func select() {
        delegate?.selectPeggleMaster(peggleMaster: peggleMaster)
    }
}
