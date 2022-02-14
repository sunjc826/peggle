import Foundation
import CoreGraphics
import Combine

class PegStatViewModel {
    var stackPegViewModel: StackPegViewModel
    var count: AnyPublisher<String, Never>

    init(peg: Peg, count: AnyPublisher<Int, Never>) {
        stackPegViewModel = StackPegViewModel(peg: peg)
        self.count = count
            .map { String($0) }
            .eraseToAnyPublisher()
    }
}
