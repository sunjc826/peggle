import UIKit
import Combine

protocol AbstractPegViewModel: ShapeDrawable {
    var peg: Peg { get }
}

extension AbstractPegViewModel {
    var fillColor: UIColor {
        peg.pegType.color
    }

    var borderColor: UIColor {
        Settings.Peg.Color.pegBorder
    }

    var shouldDrawCircle: Bool {
        peg.shape is Circle
    }

    var shouldDrawPolygon: Bool {
        peg.shape is TransformablePolygon
    }
}
