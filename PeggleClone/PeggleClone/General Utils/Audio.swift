import Foundation
import AVFoundation

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
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}
