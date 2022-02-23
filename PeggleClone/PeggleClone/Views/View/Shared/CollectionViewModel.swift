import Foundation
protocol CollectionViewModel {
    var numberOfSections: Int { get }
    func countForSection(section: Int) -> Int
}
