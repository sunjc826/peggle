import Foundation
import Combine
class LevelSelectViewModel {
    let jsonStorage = JSONStorage()
    let pngStorage = Storage(fileExtension: "png")

    var count: Int {
        let (urls, _) = jsonStorage.getAllFiles()
        return urls.count
    }

    @Published var shouldReload = false

    func getChildViewModel(for index: Int) -> LevelSelectCellViewModel {
        let (jsonURLs, jsonFilenames) = jsonStorage.getAllFiles()
        let vmLevelSelectCell = LevelSelectCellViewModel(
            levelURL: jsonURLs[index],
            levelName: jsonFilenames[index],
            pngStorage: pngStorage
        )

        vmLevelSelectCell.delegate = self

        return vmLevelSelectCell
    }
}

extension LevelSelectViewModel: LevelSelectCellViewModelDelegate {
    func delete(levelName: String) {
        do {
            try jsonStorage.delete(filename: levelName)
            try pngStorage.delete(filename: levelName)
            shouldReload = true
        } catch {
            logger.error(error.localizedDescription)
        }
        shouldReload = false
    }
}
