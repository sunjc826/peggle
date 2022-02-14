import UIKit

// reference: cocoacasts
protocol Storyboardable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle { get }
    static var storyboardIdentifier: String { get }

    static func instantiate() -> Self
}

extension Storyboardable where Self: UIViewController {
    static var storyboardName: String {
        "Main"
    }

    static var storyboardBundle: Bundle {
        .main
    }

    static var storyboardIdentifier: String {
        String(describing: self)
    }

    static func instantiate() -> Self {
        guard let viewController = UIStoryboard(
            name: storyboardName,
            bundle: storyboardBundle
        ).instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
            fatalError("should not be nil")
        }

        return viewController
    }
}
