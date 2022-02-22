import Foundation
import CoreGraphics

class EditableGameObject: GameObject, EditableGameEntity {
    var isConcrete = true

    init(shape: TransformableShape, isConcrete: Bool) {
        self.isConcrete = isConcrete
        super.init(shape: shape)
    }

    init(instance: EditableGameObject) {
        isConcrete = instance.isConcrete
        super.init(instance: instance)
    }

    static func == (lhs: EditableGameObject, rhs: EditableGameObject) -> Bool {
        lhs === rhs
    }

    override func withCenter(center: CGPoint) -> EditableGameObject {
        let copy = EditableGameObject(instance: self)
        copy.shape.center = center
        return copy
    }

    override func withScale(scale: Double) -> EditableGameObject {
        let copy = EditableGameObject(instance: self)
        copy.shape.scale = scale
        return copy
    }

    override func withRotation(rotation: Double) -> EditableGameObject {
        let copy = EditableGameObject(instance: self)
        copy.shape.rotation = rotation
        return copy
    }
}
