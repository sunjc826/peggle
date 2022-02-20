import Foundation
import AVFoundation

private let audioExtension = "wav"
private let congratulationsDirectory = "congratulations"

class Audio {
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            logger.error(error.localizedDescription)
        }
    }

    func getAudioPlayer(forProjectFile filename: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: audioExtension) else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}

extension Audio {
    func getCongrats(for peggleMaster: PeggleMaster) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: peggleMaster.id,
            withExtension: audioExtension,
            subdirectory: congratulationsDirectory
        ) else {
            return nil
        }

        return try? AVAudioPlayer(contentsOf: url)
    }
}
