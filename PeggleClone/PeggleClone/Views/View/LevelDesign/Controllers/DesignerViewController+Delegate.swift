import UIKit

extension DesignerViewController: DesignerPegButtonDelegate {
    func btnDesignerPegOnDoubleTap(sender: DesignerPegButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.selectToEdit(viewModel: sender.viewModel)
    }

    func btnDesignerPegOnLongPress(sender: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        if sender.state == .began {
            guard let btnDesignerPeg = sender.view as? DesignerPegButton else {
                fatalError("Gesture Recognizer should be attached to a PegEntityButton")
            }
            viewModel.remove(viewModel: btnDesignerPeg.viewModel)
        }
    }

    func btnDesignerPegOnPan(sender: UIPanGestureRecognizer) {
        guard let btnDesignerPeg = sender.view as? DesignerPegButton else {
            fatalError("Gesture Recognizer should be attached to a PegEntityButton")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.move(
            viewModel: btnDesignerPeg.viewModel,
            to: sender.location(in: vLayout)
        )
    }

    func btnDesignerPegOnTap(sender: DesignerPegButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        if viewModel.isDeleting {
            viewModel.remove(viewModel: sender.viewModel)
        }
    }
}

extension DesignerViewController: DesignerObstacleButtonDelegate {
    func btnDesignerObstacleOnLongPress(sender: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        if sender.state == .began {
            guard let btnDesignerObstacle = sender.view as? DesignerObstacleButton else {
                fatalError("Gesture Recognizer should be attached to a PegEntityButton")
            }
            viewModel.remove(viewModel: btnDesignerObstacle.viewModel)
        }
    }

    func btnDesignerObstacleOnPan(sender: UIPanGestureRecognizer) {
        guard let btnDesignerObstacle = sender.view as? DesignerObstacleButton else {
            fatalError("Gesture Recognizer should be attached to a PegEntityButton")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.move(
            viewModel: btnDesignerObstacle.viewModel,
            to: sender.location(in: vLayout)
        )
    }

    func btnDesignerObstacleOnTap(sender: DesignerObstacleButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        if viewModel.isDeleting {
            viewModel.remove(viewModel: sender.viewModel)
        }
    }

    func btnDesignerObstacleOnDoubleTap(sender: DesignerObstacleButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.selectToEdit(viewModel: sender.viewModel)
    }
}

extension DesignerViewController: ShapeTransformViewControllerDelegate {
    func setScale(_ scale: Double) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.scale(scale)
    }

    func setRotation(_ rotation: Double) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.rotate(rotation)
    }

}
