import UIKit

protocol ShapeDrawable {
    var fillColor: UIColor { get }
    var borderColor: UIColor { get }
}

extension ShapeDrawable {
    func setUpDrawColorConfig() {
        fillColor.setFill()
        borderColor.setStroke()
    }
}
