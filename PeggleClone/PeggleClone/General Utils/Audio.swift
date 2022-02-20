import Foundation
import AVFoundation

private let compressedAudioExtension = "mp3"
private let uncompressedAudioExtension = "wav"
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

    func getAudioPlayer(forProjectFile filename: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: uncompressedAudioExtension) else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}

extension Audio {
    func getCongrats(for peggleMaster: PeggleMaster) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: peggleMaster.id,
            withExtension: uncompressedAudioExtension,
            subdirectory: congratulationsDirectory
        ) else {
            return nil
        }

        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        return audioPlayer
    }

    func getSoundEffect(for soundEffect: SoundEffect) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: soundEffect.rawValue,
            withExtension: compressedAudioExtension,
            subdirectory: soundEffectsDirectory
        ) else {
            return nil
        }

        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        return audioPlayer
    }
}
let globalAudio = Audio()
