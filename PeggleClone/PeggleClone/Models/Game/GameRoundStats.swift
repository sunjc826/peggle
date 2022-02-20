import Foundation

struct GameRoundStats {
    let peggleMaster: PeggleMaster
    let isWon: Bool
    let score: Int
    let compulsoryPegsHit: Int
    let optionalPegsHit: Int
    let specialPegsHit: Int
}

extension GameRoundStats: Equatable {}
