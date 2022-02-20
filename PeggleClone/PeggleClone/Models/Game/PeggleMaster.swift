import Foundation

struct PeggleMaster {
    let id: String
    let name: String
    let title: String
    let description: String
    var special: SpecialType
}

extension PeggleMaster: Equatable {}
