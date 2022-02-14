import Foundation

enum PegType {
    case compulsory
    case optional
    case special
    case scoreMultiplier(multipler: Int)
}

extension PegType: Codable {}

extension PegType: CaseIterable {
    static var allCases: [PegType] {
        [.compulsory, .optional, .special, .scoreMultiplier(multipler: 2)]
    }
}

extension PegType: Hashable {}
