import Foundation

class GamePegViewModel: CoordinateMappablePegViewModel {
    var shouldLightUp: Bool {
        peg.hasCollided
    }
}
