import Foundation

final class PersistableDesignerGameLevel: Codable {
    let levelName: String
    let pegs: Set<PersistablePeg>
    let obstacles: Set<PersistableObstacle>
    let coordinateMapper: PersistableCoordinateMapper

    init(
        levelName: String,
        pegs: Set<PersistablePeg>,
        obstacles: Set<PersistableObstacle>,
        coordinateMapper: PersistableCoordinateMapper
    ) {
        self.levelName = levelName
        self.pegs = pegs
        self.obstacles = obstacles
        self.coordinateMapper = coordinateMapper
    }

    enum CodingKeys: String, CodingKey {
        case levelName
        case pegs
        case obstacles
        case coordinateMapper
    }
}
