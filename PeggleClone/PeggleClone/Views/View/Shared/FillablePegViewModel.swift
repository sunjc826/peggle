import UIKit

/// Represents a peg that fills its outer container, regardless of the underlying dimensions of the peg model.
class FillablePegViewModel: AbstractPegViewModel, AbstractFillableGameObjectViewModel {
    var gameObject: GameObject {
        peg
    }
    
    @Published var peg: Peg

    init(peg: Peg) {
        self.peg = peg
    }
}
