import Foundation
import Combine

class PeggleMasterViewModel: CollectionViewModel {
    let peggleMasters = GameData.peggleMasters
    let numberOfSections: Int = 1

    var count: Int {
        GameData.peggleMasters.count
    }

    @Published var shouldReload = false
    @Published var selectedPeggleMaster: PeggleMaster?

    init(selectedPeggleMaster: PeggleMaster?) {
        self.selectedPeggleMaster = selectedPeggleMaster
    }

    func getChildViewModel(for index: Int) -> PeggleMasterCellViewModel {
        let vmPeggleMasterCell = PeggleMasterCellViewModel(
            peggleMaster: peggleMasters[index]
        )

        vmPeggleMasterCell.delegate = self

        return vmPeggleMasterCell
    }
}

extension PeggleMasterViewModel: PeggleMasterCellViewModelDelegate {
    var selectedPeggleMasterPublisher: AnyPublisher<PeggleMaster?, Never> {
        $selectedPeggleMaster.eraseToAnyPublisher()
    }

    func selectPeggleMaster(peggleMaster: PeggleMaster) {
        selectedPeggleMaster = peggleMaster
    }
}
