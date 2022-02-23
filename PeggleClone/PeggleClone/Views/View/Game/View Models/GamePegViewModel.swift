import Foundation
import CoreGraphics

class GamePegViewModel: CoordinateMappablePegViewModel {
    var shouldLightUp: Bool {
        peg.hasCollided
    }
}
