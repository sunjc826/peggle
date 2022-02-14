import Foundation

struct GameRoundStats {
    let isWon: Bool
    let score: Int
    let compulsoryPegsHit: Int
    let optionalPegsHit: Int
    let specialPegsHit: Int
}

extension GameRoundStats: Equatable {}
