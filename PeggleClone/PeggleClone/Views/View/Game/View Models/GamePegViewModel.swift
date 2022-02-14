import UIKit
import Combine

class GamePegViewModel: CoordinateMappablePegViewModel {
    var shouldLightUp: Bool {
        peg.hasCollided
    }
}
