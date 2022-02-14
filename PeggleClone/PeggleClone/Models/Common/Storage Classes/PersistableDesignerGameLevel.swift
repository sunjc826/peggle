import Foundation

final class PersistableDesignerGameLevel: Codable {
    let levelName: String
    let pegs: Set<PersistablePeg>
    let playArea: PersistablePlayArea

    init(levelName: String, pegs: Set<PersistablePeg>, playArea: PersistablePlayArea) {
        self.levelName = levelName
        self.pegs = pegs
        self.playArea  = playArea
    }

    enum CodingKeys: String, CodingKey {
        case levelName
        case pegs
        case playArea
    }
}
