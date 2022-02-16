import Foundation

struct PeggleMaster {
    let id: String
    let name: String
    let title: String
    let description: String
    let special: SpecialType
}

extension PeggleMaster: Equatable {}
