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
    let compulsoryPegs = arr.map { Peg(shape: $0, pegType: .compulsory, isConcrete: false) }
    let optionalPegs = arr.map { Peg(shape: $0, pegType: .optional, isConcrete: false) }
    let merged = compulsoryPegs + optionalPegs
    return merged
}()

class PaletteViewModel {
    private var subscriptions: Set<AnyCancellable> = []

    var palettePegViewModels: [PalettePegViewModel] = []

    @Published var selectedPegInPalette: Peg?
    @Published var isDeleting = false

    init() {
        setupChildViewModels()
        setupBindings()
    }

    private func setupChildViewModels() {
        palettePegViewModels = palettePegs.map { PalettePegViewModel(peg: $0) }
        palettePegViewModels.forEach { $0.delegate = self }
    }

    private func setupBindings() {
        $selectedPegInPalette.sink { [weak self] selectedPeg in
            guard let self = self else {
                return
            }

            for model in self.palettePegViewModels {
                model.isSelected = model.peg === selectedPeg
            }
        }
        .store(in: &subscriptions)

        $isDeleting.sink { [weak self] isDeleting in
            if isDeleting {
                self?.selectedPegInPalette = nil
            }
        }
        .store(in: &subscriptions)
    }
}

extension PaletteViewModel: PalettePegViewModelDelegate {
    func toggleSelectInPalette(peg: Peg) {
        if isDeleting {
            isDeleting = false
        }

        if selectedPegInPalette == nil || selectedPegInPalette !== peg {
            selectedPegInPalette = peg
        } else {
            selectedPegInPalette = nil
        }

    }
}
