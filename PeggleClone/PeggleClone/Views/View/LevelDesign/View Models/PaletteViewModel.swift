import UIKit
import Combine

private let palettePegs: [Peg] = {
    var arr: [TransformableShape] = []
    let circle = CircleObject()
    arr.append(circle)
    for sides in 3...10 {
        let shape = RegularPolygonObject(
            center: CGPoint.zero,
            sides: sides
        ).getTransformablePolygon()
        arr.append(shape)
    }
    return arr.map { Peg(shape: $0, pegType: .compulsory, isConcrete: false) }
}()

class PaletteViewModel {
    private var subscriptions: Set<AnyCancellable> = []

    var paletteObstacleViewModel: PaletteObstacleButtonViewModel
    var palettePegViewModels: [PalettePegButtonViewModel] = []
    var pegTypeViewModels: [PegTypeButtonViewModel] = []

    @Published var isObstacleSelected = false
    @Published var selectedPegType = PegType.compulsory
    @Published var selectedPegInPalette: Peg?
    @Published var isDeleting = false

    init() {
        paletteObstacleViewModel = PaletteObstacleButtonViewModel()
        paletteObstacleViewModel.delegate = self
        setupChildViewModels()
        setupBindings()
    }

    private func setupChildViewModels() {
        palettePegViewModels = palettePegs.map { PalettePegButtonViewModel(peg: $0) }
        palettePegViewModels.forEach { $0.delegate = self }
        pegTypeViewModels = PegType.allCases.map { PegTypeButtonViewModel(pegType: $0) }
        pegTypeViewModels.forEach { $0.delegate = self }
    }

    private func setupBindings() {
        $isObstacleSelected.removeDuplicates().sink { [weak self] isObstacleSelected in
            guard let self = self else {
                return
            }

            guard isObstacleSelected else {
                return
            }

            self.selectedPegInPalette = nil
            self.isDeleting = false
        }
        .store(in: &subscriptions)

        $selectedPegInPalette.removeDuplicates().sink { [weak self] selectedPegInPalette in
            guard let self = self else {
                return
            }

            guard selectedPegInPalette != nil else {
                return
            }

            self.isDeleting = false
            self.isObstacleSelected = false
        }
        .store(in: &subscriptions)

        $isDeleting.removeDuplicates().sink { [weak self] isDeleting in
            guard let self = self else {
                return
            }

            guard isDeleting else {
                return
            }

            self.selectedPegInPalette = nil
            self.isObstacleSelected = false
        }
        .store(in: &subscriptions)

        $selectedPegType.removeDuplicates().sink { [weak self] selectedPegType in
            guard let self = self else {
                return
            }

            self.selectedPegInPalette = nil

            for model in self.pegTypeViewModels {
                model.isSelected = model.pegType == selectedPegType
            }

            for model in self.palettePegViewModels {
                model.setPegType(pegType: selectedPegType)
            }
        }
        .store(in: &subscriptions)
    }
}

extension PaletteViewModel: PalettePegViewModelDelegate {
    var selectedPalettePegPublisher: AnyPublisher<Peg?, Never> {
        $selectedPegInPalette.eraseToAnyPublisher()
    }

    func toggleSelectInPalette(peg: Peg) {
        isDeleting = false

        if selectedPegInPalette == nil || selectedPegInPalette !== peg {
            selectedPegInPalette = peg
        } else {
            selectedPegInPalette = nil
        }
    }
}

extension PaletteViewModel: PegTypeButtonViewModelDelegate {
    func selectPegType(pegType: PegType) {
        if selectedPegType != pegType {
            selectedPegType = pegType
        }
    }
}

extension PaletteViewModel: PaletteObstacleButtonViewModelDelegate {
    var isObstacleSelectedPublisher: AnyPublisher<Bool, Never> {
        $isObstacleSelected.eraseToAnyPublisher()
    }

    func toggleSelectObstacleInPalette() {
        isDeleting = false
        selectedPegInPalette = nil
        isObstacleSelected.toggle()
    }
}
