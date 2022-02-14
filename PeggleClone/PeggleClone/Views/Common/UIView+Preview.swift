#if DEBUG
import Foundation
import UIKit
import SwiftUI
extension UIView {
    private struct Preview: UIViewRepresentable {
        // swiftlint:disable nesting
        typealias UIViewType = UIView
        // swiftlint:enable nesting
        let view: UIView
        func makeUIView(context: Context) -> UIView {
            view
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }

    func toPreview() -> some View {
        Preview(view: self)
    }
}
#endif
