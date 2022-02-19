import Foundation
import CoreGraphics

extension CGRect {
    init(rectangle: Rectangle) {
        self.init(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: rectangle.height)
    }

    func withWidth(width: Double) -> CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }

    func withHeight(height: Double) -> CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }
}
