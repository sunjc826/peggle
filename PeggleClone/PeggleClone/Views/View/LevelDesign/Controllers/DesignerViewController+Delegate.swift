import UIKit

extension DesignerViewController: PegEntityButtonDelegate {
    func pegEntityButtonOnDoubleTap(sender: DesignerPegButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.selectToEdit(viewModel: sender.viewModel)
    }

    func pegEntityButtonOnLongPress(sender: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectPeg()
        if sender.state == .began {
            guard let pegEntityButton = sender.view as? DesignerPegButton else {
                fatalError("Gesture Recognizer should be attached to a PegEntityButton")
            }
            viewModel.remove(pegViewModel: pegEntityButton.viewModel)
        }
    }

    func pegEntityButtonOnPan(sender: UIPanGestureRecognizer) {
        guard let pegEntityButton = sender.view as? DesignerPegButton else {
            fatalError("Gesture Recognizer should be attached to a PegEntityButton")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.move(
            pegViewModel: pegEntityButton.viewModel,
            to: sender.location(in: vLayout)
        )
    }

    func pegEntityButtonOnTap(sender: DesignerPegButton) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        if viewModel.isDeleting {
            viewModel.remove(pegViewModel: sender.viewModel)
        }
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
