import Foundation
import Combine

class GenericStatViewModel {
    var key: String
    var value: AnyPublisher<String, Never>

    init<T>(key: String, value: AnyPublisher<T, Never>) {
        self.key = key
        self.value = value.map { obj -> String in
            String(describing: obj)
        }.eraseToAnyPublisher()
    }
}
