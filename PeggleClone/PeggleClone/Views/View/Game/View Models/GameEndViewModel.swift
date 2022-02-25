import UIKit
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

    var gameImagePublisher: AnyPublisher<UIImage?, Never> {
        gameImage.eraseToAnyPublisher()
    }
    private var gameImage: PassthroughSubject<UIImage?, Never> = PassthroughSubject()

    var audio: AVAudioPlayer?

    init(stats: GameRoundStats) {
        self.stats = stats
        audio = stats.isWon ? globalAudio.getCongrats(for: stats.peggleMaster) : globalAudio.getEncouragement()
        DispatchQueue.global().async {
            let trailing = stats.isWon ? "win" : "lose"
            let image = UIImage(named: "\(stats.peggleMaster.id)_\(trailing)")

            DispatchQueue.main.async {
                self.gameImage.send(image)
            }
        }
    }
}
