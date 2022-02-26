import Foundation
import Combine

class DesignerMainViewModel {
    class ChildViewModels {
        var designerViewModel: DesignerViewModel
        var paletteViewModel: PaletteViewModel
        var storageViewModel: StorageViewModel
        init(
            designerViewModel: DesignerViewModel,
            paletteViewModel: PaletteViewModel,
            storageViewModel: StorageViewModel
        ) {
            self.designerViewModel = designerViewModel
            self.paletteViewModel = paletteViewModel
            self.storageViewModel = storageViewModel
        }
    }

    private var designerViewModel: DesignerViewModel
    private var paletteViewModel: PaletteViewModel
    private var storageViewModel: StorageViewModel
    private var subscriptions: Set<AnyCancellable> = []

    var levelName: String? {
        get {
            designerViewModel.gameLevel?.levelName
        } set {
            designerViewModel.gameLevel?.levelName = newValue
        }
    }

    var decodedGameLevel: PersistableDesignerGameLevel?

    var gameLevel: DesignerGameLevel? {
        designerViewModel.gameLevel
    }

    let jsonStorage = JSONStorage()
    let pngStorage = Storage(fileExtension: "png")

    init() {
        paletteViewModel = PaletteViewModel()
        designerViewModel = DesignerViewModel(
            paletteViewModel: paletteViewModel,
            shapeTransformViewModel: ShapeTransformViewModel()
        )
        storageViewModel = StorageViewModel()

        setupBindings()
    }

    private func setupBindings() {
        designerViewModel.$gameLevel
            .compactMap { $0 }
            .sink { [weak self] gameLevel in
                self?.storageViewModel.levelNamePublisher = gameLevel.$levelName.eraseToAnyPublisher()
            }
            .store(in: &subscriptions)
    }

    func getChildViewModels() -> ChildViewModels {
        ChildViewModels(
            designerViewModel: designerViewModel,
            paletteViewModel: paletteViewModel,
            storageViewModel: storageViewModel
        )
    }

    @discardableResult
    func saveLevel(imageData: Data, updateDecodedLevel: Bool = false) throws -> URL? {
        let levelName = try checkBeforeTransition()
        guard let gameLevel = gameLevel else {
            return nil
        }

        do {
            try jsonStorage.encodeAndSave(object: gameLevel.toPersistable(), filename: levelName)
            try pngStorage.save(data: imageData, filename: levelName)

            if updateDecodedLevel {
                decodedGameLevel = try jsonStorage.loadAndDecode(filename: levelName)
            }

            return try jsonStorage.getURL(filename: levelName)
        } catch {
            globalLogger.error("\(error)")
        }
        return nil
    }

    @discardableResult
    func checkBeforeTransition() throws -> String {
        guard let gameLevel = gameLevel else {
            fatalError("game level should be present")
        }

        guard let levelName = levelName, !levelName.isBlank else {
            throw TransitionError.nameBlank
        }

        guard gameLevel.isConsistent() else {
            throw TransitionError.inconsistent
        }
        return levelName
    }

    func tearDownBeforeTransition() {
        designerViewModel.tearDownBeforeTransition()
    }

    func resetLevel() {
        gameLevel?.reset()
    }

    func removeInconsistencies() {
        gameLevel?.removeInconsistencies()
    }

    func loadLevel(url: URL) {
        do {
            decodedGameLevel = try jsonStorage.loadAndDecode(from: url)

            guard let decodedGameLevel = decodedGameLevel else {
                return
            }

            gameLevel?.hydrate(with: decodedGameLevel)
        } catch {
            globalLogger.error("\(error)")
        }

    }
}
