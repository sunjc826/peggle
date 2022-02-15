import UIKit
import Combine

/// Controls the palette, which includes the delete button.
class PaletteViewController: UIViewController {
    @IBOutlet private var svPalette: UIStackView!
    @IBOutlet private var btnDelete: UIButton!
    @IBOutlet private var svColor: UIStackView!

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

        let palettePegButtons = viewModel.palettePegViewModels.map { palettePegViewModel in
            PalettePegButton(viewModel: palettePegViewModel)
        }
        palettePegButtons.forEach { button in
            svPalette.addArrangedSubview(button)
            resizeButton(button: button)
            setupConstraints(for: button)
        }

        let pegTypeButtons = viewModel.pegTypeViewModels.map { pegTypeViewModel in
            PegTypeButton(viewModel: pegTypeViewModel)
        }

        pegTypeButtons.forEach { button in
            svColor.addArrangedSubview(button)
            resizeButton(button: button)
            setupConstraints(for: button)
        }

        svPalette.setNeedsLayout()
        svPalette.setNeedsDisplay()
        svColor.setNeedsLayout()
        svColor.setNeedsDisplay()
    }

    private func resizeButton(button: UIButton) {
        button.transform = CGAffineTransform(uniformScale: 0.7)
    }

    private func setupConstraints(for button: UIButton) {
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
