import Foundation
import Combine

class PeggleMasterViewModel: CollectionViewModel {
    let peggleMasters = GameData.peggleMasters
    let numberOfSections: Int = 1

    @Published var shouldReload = false
    @Published var selectedPeggleMaster: PeggleMaster?

    init(selectedPeggleMaster: PeggleMaster?) {
        self.selectedPeggleMaster = selectedPeggleMaster
    }

    func countForSection(section: Int) -> Int {
        GameData.peggleMasters.count
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
