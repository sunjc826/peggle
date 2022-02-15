import Foundation

enum SpecialType {
    case normal
    case spooky(activeCount: Int = 0)
    case explosive
    case moonTourist
    case multiball
    case cheater
}

extension SpecialType: Equatable {}
