import UIKit
import Combine

protocol LevelSelectCellViewModelDelegate: AnyObject {
    func delete(levelName: String)
}

class LevelSelectCellViewModel {
    weak var delegate: LevelSelectCellViewModelDelegate?

    @Published private(set) var text: String?

    /// Preview image of the level.
    @Published private(set) var backgroundImage: UIImage?

    /// Local storage URL associated with the level.
    var levelURL: URL

    private var levelName: String

    init(levelURL: URL, levelName: String, pngStorage: Storage) {
        self.levelURL = levelURL
        self.levelName = levelName
        text = levelName
        DispatchQueue.global().async { [self] in
            do {
                let imageData = try pngStorage.load(filename: levelName)
                let image = UIImage(data: imageData)
                DispatchQueue.main.async { [self] in
                    self.backgroundImage = image
                }
            } catch {
                globalLogger.error(error.localizedDescription)
            }
        }
    }

    func delete() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.delete(levelName: levelName)
    }
}
