import UIKit
// reference: https://www.andrewcbancroft.com/
typealias Completion = (Bool) -> Void
extension UIView {
    func fadeIn(completion: @escaping Completion) {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.alpha = 1.0
            },
            completion: completion
        )
    }

    func fadeOut(completion: @escaping Completion) {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 0.0
            },
            completion: completion
        )
    }
}
