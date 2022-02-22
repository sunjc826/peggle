import Foundation
import CoreGraphics

class PhysicalProperties {
    var backingShape: TransformableShape
    var uniformDensity: Double {
        didSet {
            assert(uniformDensity > 0)
        }
    }
    var mass: Double
    var inverseMass: Double {
        1 / mass
    }
    var momentOfInertia: Double
    var inverseMomentOfInertia: Double {
        1 / momentOfInertia
    }
    var elasticity: Double {
        didSet {
            assert(0 <= elasticity && elasticity <= 1)
        }
    }

    init(backingShape: TransformableShape, uniformDensity: Double, elasticity: Double) {
        self.backingShape = backingShape
        self.uniformDensity = uniformDensity
        self.mass = backingShape.area * uniformDensity
        self.momentOfInertia = backingShape.areaMomentOfInertia *
            uniformDensity /
            Settings.easeOfRotation.rawValue
        self.elasticity = elasticity
    }

    convenience init(instance: PhysicalProperties) {
        switch instance.backingShape {
        case let circle as CircleObject:
            self.init(backingShape: CircleObject(instance: circle),
                      uniformDensity: instance.uniformDensity,
                      elasticity: instance.elasticity
            )
        case let polygon as TransformablePolygonObject:
            self.init(backingShape: TransformablePolygonObject(instance: polygon),
                      uniformDensity: instance.uniformDensity,
                      elasticity: instance.elasticity
            )
        default:
            fatalError("unexpected type")
        }
    }
}
