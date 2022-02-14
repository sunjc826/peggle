import UIKit
import Combine

private let compulsoryColor = UIColor.orange
private let optionalColor = UIColor.blue
private let specialColor = UIColor.green
private let scoreMultiplierColor = UIColor.purple
private let pegBorderColor = UIColor.black

protocol AbstractPegViewModel: ShapeDrawable {
    var peg: Peg { get }
}

extension AbstractPegViewModel {
    var fillColor: UIColor {
        switch peg.pegType {
        case .compulsory:
            return compulsoryColor
        case .optional:
            return optionalColor
        case .special:
            return specialColor
        case .scoreMultiplier:
            return scoreMultiplierColor
        }
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
