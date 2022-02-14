import UIKit
import Combine

private let compulsoryColor = UIColor.orange
private let optionalColor = UIColor.blue
private let pegBorderColor = UIColor.black

protocol AbstractPegViewModel: ShapeDrawable {
    var peg: Peg { get }
}

extension AbstractPegViewModel {
    var fillColor: UIColor {
        peg.isCompulsory ? compulsoryColor : optionalColor
    }

    var borderColor: UIColor {
        pegBorderColor
    }

    var shouldDrawCircle: Bool {
        peg.shape is Circle
    }

    var shouldDrawPolygon: Bool {
        peg.shape is TransformablePolygon
    }
}
