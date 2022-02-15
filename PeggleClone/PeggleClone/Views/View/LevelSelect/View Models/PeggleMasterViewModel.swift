import Foundation
import Combine

class PeggleMasterViewModel: CollectionViewModel {

    let numberOfSections: Int = 1
    
    var count: Int {
        0
    }

    @Published var shouldReload = false

    func getChildViewModel(for index: Int) -> PeggleMasterCellViewModel {
        let vmPeggleMasterCell = PeggleMasterCellViewModel()

        vmPeggleMasterCell.delegate = self

        return vmPeggleMasterCell
    }
}

extension PeggleMasterViewModel: PeggleMasterCellViewModelDelegate {}
