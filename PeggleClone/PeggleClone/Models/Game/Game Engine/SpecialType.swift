import Foundation

enum SpecialType {
    case normal
    case spooky(activeCount: Int = 0)
    case smallBombs
    case blackHole
    case iHatePeople
    case moonTourist
    case multiball
    case superDuperGuide(activeCount: Int = 0)
    case phaseThrough(activeCount: Int = 0)
}

extension SpecialType {
    var name: String {
        switch self {
        case .normal:
            return "Normal"
        case .spooky(activeCount: _):
            return "Spookyball"
        case .smallBombs:
            return "Small Bombs"
        case .blackHole:
            return "Black Hole"
        case .iHatePeople:
            return "Repulsor"
        case .moonTourist:
            return "Moon Tourist"
        case .multiball:
            return "Multiball"
        case .superDuperGuide(activeCount: _):
            return "Super Duper Guide"
        case .phaseThrough(activeCount: _):
            return "Phaser"
        }
    }

    var description: String {
        switch self {
        case .normal:
            return "No ability"
        case .spooky(activeCount: _):
            return "Ball wraps around"
        case .smallBombs:
            return "Explosions"
        case .blackHole:
            return "Attract nearby pegs"
        case .iHatePeople:
            return "Repel nearby pegs"
        case .moonTourist:
            return "Reduced gravity"
        case .multiball:
            return "Spawn more balls"
        case .superDuperGuide:
            return "See (more) of the future"
        case .phaseThrough(activeCount: _):
            return "Phase through walls"
        }
    }
}

extension SpecialType: Equatable {}
