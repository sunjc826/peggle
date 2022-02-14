import UIKit
import Combine

/// Controls the palette, which includes the delete button.
class PaletteViewController: UIViewController {
    @IBOutlet private var svPalette: UIStackView!
    @IBOutlet private var btnDelete: UIButton!

    var viewModel: PaletteViewModel?

    private var subscriptions: Set<AnyCancellable> = []

    func duringParentViewDidAppear() {
        setupButtons()
        setupBindings()
        registerEventHandlers()
    }

    func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$isDeleting
            .sink { [weak self] isDeleting in
                self?.refreshDeleteButton(isDeleting: isDeleting)
            }
            .store(in: &subscriptions)
    }

    private func setupButtons() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let buttons = viewModel.palettePegViewModels.map { palettePegViewModel in
            PalettePegButton(
                viewModel: palettePegViewModel
            )
        }
        buttons.forEach { button in
            svPalette.addArrangedSubview(button)
            resizeButton(button: button)
            setupConstraints(button: button)
        }
        svPalette.setNeedsLayout()
        svPalette.setNeedsDisplay()
    }

    private func resizeButton(button: PalettePegButton) {
        button.transform = CGAffineTransform(uniformScale: 0.7)
    }

    private func setupConstraints(button: PalettePegButton) {
        let constraints = [
            button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor),
            button.heightAnchor.constraint(equalTo: button.superview!.heightAnchor),
            button.widthAnchor.constraint(equalTo: button.superview!.heightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
    }

    private func registerEventHandlers() {
        btnDelete.addTarget(self, action: #selector(self.deleteOnTap), for: .touchUpInside)
    }

    private func refreshDeleteButton(isDeleting: Bool) {
        btnDelete.backgroundColor = isDeleting ?
            UIColor.blue :
            UIColor.white
    }

    @IBAction private func deleteOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.isDeleting = true
    }
}
