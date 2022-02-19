import UIKit

extension DesignerViewController: DesignerPegButtonDelegate {
    func btnDesignerPegOnDoubleTap(sender: DesignerPegButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.selectToEditAndDeselectIfAlreadyEditing(viewModel: sender.viewModel)
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
            fatalError("Gesture Recognizer should be attached to a DesignerObstacleButton")
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

        viewModel.selectToEditAndDeselectIfAlreadyEditing(viewModel: sender.viewModel)
    }

    func btnDesignerObstacleVertexOnPan(
        sender: UIPanGestureRecognizer,
        vmDesignerObstacleButton: DesignerObstacleButtonViewModel,
        vertexIndex: Int
    ) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.relocateObstacleVertex(
            of: vmDesignerObstacleButton,
            at: vertexIndex,
            to: sender.location(in: vLayout)
        )
    }

    func btnDesignerObstacleOscillationLocalityOnPan(
        vmDesignerObstacleButton: DesignerObstacleButtonViewModel,
        radius: Double
    ) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.setOscillationRadius(of: vmDesignerObstacleButton, to: radius)
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

extension DesignerViewController: DesignerScrollViewDelegate {
    func scrollvDesignerOnPan(dy: Double) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.scroll(dy: dy)
    }

    func scrollvDesignerEndPan() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.terminateScroll()
    }
}
