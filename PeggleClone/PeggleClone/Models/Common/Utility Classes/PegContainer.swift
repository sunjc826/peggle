import Foundation
import Combine

class PegContainer: Container {
    typealias Element = Peg

    private var pegs: AnyContainer<Peg>
    @Published var pegCounts: [PegType: Int] = [:]
    @Published var pegHits: [PegType: Int] = [:]
    @Published var pegScores: [PegType: Int] = [:]

    var compulsoryPegCount: Int {
        guard let count = pegCounts[.compulsory] else {
            fatalError("should not be nil")
        }

        return count
    }

    init<T: Container>(pegs: T) where T.Element == Peg {
        self.pegs = AnyContainer(container: pegs)
        setup()
    }

    private func setup() {
        PegType.allCases.forEach { pegType in
            pegCounts[pegType] = 0
            pegHits[pegType] = 0
            pegScores[pegType] = 0
        }

        for peg in pegs {
            guard let count = pegCounts[peg.pegType] else {
                fatalError("should not be nil")
            }
            pegCounts[peg.pegType] = count + 1
        }
    }

    func insert(_ entity: Peg) {
        guard !pegs.contains(entity) else {
            return
        }

        guard let count = pegCounts[entity.pegType] else {
            fatalError("should not be nil")
        }

        pegCounts[entity.pegType] = count + 1
        pegs.insert(entity)
    }

    func makeIterator() -> AnyIterator<Peg> {
        pegs.makeIterator()
    }

    func update(oldPeg: Peg, with newPeg: Peg) {
        pegs.remove(oldPeg)
        pegs.insert(newPeg)
    }

    func remove(_ entity: Peg) {
        guard pegs.contains(entity) else {
            return
        }

        guard let count = pegCounts[entity.pegType],
              let hits = pegHits[entity.pegType],
              let score = pegScores[entity.pegType]
        else {
            fatalError("should not be nil")
        }

        pegCounts[entity.pegType] = count - 1
        pegHits[entity.pegType] = hits + 1
        pegScores[entity.pegType] = score + entity.pegType.score
        pegs.remove(entity)
    }

    func removeAll() {
        for key in pegCounts.keys {
            pegCounts.updateValue(0, forKey: key)
            pegHits.updateValue(0, forKey: key)
            pegScores.updateValue(0, forKey: key)
        }
        pegs.removeAll()
    }
}
