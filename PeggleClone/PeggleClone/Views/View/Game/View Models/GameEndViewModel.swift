import Foundation
import Combine

class GameEndViewModel {
    let stats: GameRoundStats

    var gameStatusText: String {
        stats.isWon ? "Congratulations! Nipahh" : "See you next time..."
    }

    init(stats: GameRoundStats) {
        self.stats = stats
    }
}
