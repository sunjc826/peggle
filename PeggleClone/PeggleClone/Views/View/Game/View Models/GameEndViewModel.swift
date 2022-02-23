import Foundation
import Combine
import AVFoundation

class GameEndViewModel {
    let stats: GameRoundStats

    var gameStatusText: String {
        stats.isWon ? """
            Congratulations! You have beaten the Golden Witch's gameboard!
            """ : """
            Fight on! Nipahhh~\u{2606}
            Lady Bernkastel cheers you on.
            """
    }

    var audio: AVAudioPlayer?

    init(stats: GameRoundStats) {
        self.stats = stats
        audio = stats.isWon ? globalAudio.getCongrats(for: stats.peggleMaster) : globalAudio.getEncouragement()
    }
}
