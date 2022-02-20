import Foundation
import Combine
import AVFoundation

class GameEndViewModel {
    let stats: GameRoundStats

    var gameStatusText: String {
        stats.isWon ? "Congratulations! Nipahh" : "See you next time..."
    }

    var audio: AVAudioPlayer?

    init(stats: GameRoundStats) {
        self.stats = stats
        audio = globalAudio.getCongrats(for: stats.peggleMaster)
        audio?.prepareToPlay()
    }
}
