import Foundation

class PegContainer: Container {
    typealias Element = Peg

    private var pegs: AnyContainer<Peg>
    @Published var pegCount: [PegType: Int] = [:]

    init<T: Container>(pegs: T) where T.Element == Peg {
        self.pegs = AnyContainer(container: pegs)
        setupCounts()
    }

    private func setupCounts() {
        PegType.allCases.forEach { pegType in
            pegCount[pegType] = 0
        }

        for peg in pegs {
            guard let count = pegCount[peg.pegType] else {
                fatalError("should not be nil")
            }
            pegCount[peg.pegType] = count + 1
        }
    }

    func insert(_ entity: Peg) {
        pegs.insert(entity)
    }

    func makeIterator() -> AnyIterator<Peg> {
        pegs.makeIterator()
    }

    func remove(_ entity: Peg) {
        pegs.remove(entity)
    }

    func removeAll() {
        pegs.removeAll()
    }
}
