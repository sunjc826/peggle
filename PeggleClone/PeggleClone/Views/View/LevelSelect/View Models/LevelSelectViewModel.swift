import Foundation
import Combine
class LevelSelectViewModel: CollectionViewModel {
    let jsonStorage = JSONStorage()
    let pngStorage = Storage(fileExtension: "png")

    let numberOfSections: Int = 2

    @Published var shouldReload = false

    func countForSection(section: Int) -> Int {
        switch section {
        case 0:
            let preloadedLevels = jsonStorage.getPreloadedLevels()
            return preloadedLevels.count
        case 1:
            let (urls, _) = jsonStorage.getAllFiles()
            return urls.count
        default:
            fatalError("unexpected section")
        }
    }

    func getChildViewModel(for section: Int, at index: Int) -> LevelSelectCellViewModel {
        let vmLevelSelectCell: LevelSelectCellViewModel
        switch section {
        case 0:
            let preloadLevelData = jsonStorage.getPreloadedLevels()
            vmLevelSelectCell = LevelSelectCellViewModel(
                isPreloaded: true,
                levelURL: preloadLevelData[index].jsonURL,
                levelName: preloadLevelData[index].jsonFilename,
                imageURL: preloadLevelData[index].imageURL,
                pngStorage: pngStorage
            )
        case 1:
            let (jsonURLs, jsonFilenames) = jsonStorage.getAllFiles()
            vmLevelSelectCell = LevelSelectCellViewModel(
                isPreloaded: false,
                levelURL: jsonURLs[index],
                levelName: jsonFilenames[index],
                imageURL: try? pngStorage.getURL(filename: jsonFilenames[index]),
                pngStorage: pngStorage
            )
        default:
            fatalError("unexpected section")
        }

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
            globalLogger.error(error.localizedDescription)
        }
        shouldReload = false
    }
}
