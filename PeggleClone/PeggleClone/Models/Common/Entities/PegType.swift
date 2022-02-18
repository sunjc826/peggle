import UIKit

enum PegType {
    case compulsory
    case optional
    case special
    case valuable(score: Int = 100)
}

extension PegType: Codable {}

extension PegType: CaseIterable {
    static var allCases: [PegType] {
        [.compulsory, .optional, .special, .valuable(score: 100)]
    }
}

extension PegType: Hashable {}

extension PegType {
    var score: Int {
        switch self {
        case .compulsory:
            return 25
        case .optional:
            return 10
        case .special:
            return 10
        case .valuable(score: let score):
            return score
        }
    }
}

extension PegType {
    var color: UIColor {
        switch self {
        case .compulsory:
            return Settings.Peg.Color.compulsory
        case .optional:
            return Settings.Peg.Color.optional
        case .special:
            return Settings.Peg.Color.special
        case .valuable:
            return Settings.Peg.Color.scoreMultiplier
        }
    }
}
