import Foundation
import CoreGraphics

extension CGRect {
    init(rectangle: Rectangle) {
        self.init(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: rectangle.height)
    }
}
