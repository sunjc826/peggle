import Foundation

enum SpecialType {
    case normal
    case spooky(activeCount: Int = 0)
    case smallBombs
    case blackHole
    case iHatePeople
    case moonTourist // lower gravity for the same ball
    case multiball
    case author // hax
}

extension SpecialType: Equatable {}
