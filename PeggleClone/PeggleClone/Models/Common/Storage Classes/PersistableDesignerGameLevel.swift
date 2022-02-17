import Foundation

final class PersistableDesignerGameLevel: Codable {
    let levelName: String
    let pegs: Set<PersistablePeg>
    let obstacles: Set<PersistableObstacle>
    let playArea: PersistablePlayArea

    init(
        levelName: String,
        pegs: Set<PersistablePeg>,
        obstacles: Set<PersistableObstacle>,
        playArea: PersistablePlayArea
    ) {
        self.levelName = levelName
        self.pegs = pegs
        self.obstacles = obstacles
        self.playArea  = playArea
    }

    enum CodingKeys: String, CodingKey {
        case levelName
        case pegs
        case obstacles
        case playArea
    }
}
