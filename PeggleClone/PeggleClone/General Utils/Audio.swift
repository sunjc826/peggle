import Foundation
import AVFoundation

private let extensions = ["wav", "mp3"]
private let congratulationsDirectory = "congratulations"
private let soundEffectsDirectory = "sound_effects"

class Audio {
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            globalLogger.error(error.localizedDescription)
        }
    }
}

extension Audio {
    func getCongrats(for peggleMaster: PeggleMaster) -> AVAudioPlayer? {
        var url: URL?
        for ext in extensions {
            url = Bundle.main.url(
                forResource: peggleMaster.id,
                withExtension: ext,
                subdirectory: congratulationsDirectory
            )

            if url != nil {
                break
            }
        }

        guard let url = url else {
            return nil
        }

        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        return audioPlayer
    }

    func getSoundEffect(for soundEffect: SoundEffect) -> AVAudioPlayer? {
        var url: URL?
        for ext in extensions {
            url = Bundle.main.url(
                forResource: soundEffect.rawValue,
                withExtension: ext,
                subdirectory: soundEffectsDirectory
            )

            if url != nil {
                break
            }
        }

        guard let url = url else {
            return nil
        }

        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        return audioPlayer
    }
}
let globalAudio = Audio()
