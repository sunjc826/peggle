import UIKit
import Combine

class CoordinateMappablePegViewModel: AbstractPegViewModel, AbstractCoordinateMappableGameObjectViewModel {
    weak var delegate: CoordinateMappableViewModelDelegate?

    var gameObject: EditableGameObject {
        peg
    }

    var peg: Peg

    init(peg: Peg) {
        self.peg = peg
    }
}
