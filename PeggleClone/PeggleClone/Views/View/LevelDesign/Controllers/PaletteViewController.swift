import UIKit
import Combine

/// Controls the palette, which includes the delete button.
class PaletteViewController: UIViewController {
    @IBOutlet private var svPalette: UIStackView!
    @IBOutlet private var btnDelete: UIButton!
    @IBOutlet private var svColor: UIStackView!
    @IBOutlet private var btnObstacle: PaletteObstacleButton!

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
            .removeDuplicates()
            .sink { [weak self] isDeleting in
                self?.refreshDeleteButton(isDeleting: isDeleting)
            }
            .store(in: &subscriptions)
    }

    private func setupButtons() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        svPalette.translatesAutoresizingMaskIntoConstraints = false

        svPalette.arrangedSubviews.forEach { $0.removeFromSuperview() }
        svColor.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let palettePegButtons = viewModel.palettePegViewModels.map { palettePegViewModel in
            PalettePegButton(viewModel: palettePegViewModel)
        }
        palettePegButtons.forEach { button in
            svPalette.addArrangedSubview(button)
            resizeButton(button)
            setupConstraintsForPalettePegButton(button)
        }

        let pegTypeButtons = viewModel.pegTypeViewModels.map { pegTypeViewModel in
            PegTypeButton(viewModel: pegTypeViewModel)
        }

        pegTypeButtons.forEach { button in
            svColor.addArrangedSubview(button)
            resizeButton(button)
            setupConstraintsForPegTypeButton(button)
        }

        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        svColor.addArrangedSubview(spacerView)

        btnObstacle.viewModel = viewModel.paletteObstacleViewModel

        svPalette.setNeedsLayout()
        svPalette.setNeedsDisplay()
        svColor.setNeedsLayout()
        svColor.setNeedsDisplay()
    }

    private func resizeButton(_ button: UIButton) {
        button.transform = CGAffineTransform(uniformScale: 0.7)
    }

    private func setupConstraintsForPalettePegButton(_ button: UIButton) {
        let constraints = [
            button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor),
            button.heightAnchor.constraint(equalTo: button.superview!.heightAnchor),
            button.widthAnchor.constraint(equalTo: button.superview!.heightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
    }

    private func setupConstraintsForPegTypeButton(_ button: UIButton) {
        let constraints = [
            button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor),
            button.heightAnchor.constraint(equalTo: button.superview!.heightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
    }

    private func registerEventHandlers() {
        btnDelete.addTarget(self, action: #selector(self.btnDeleteOnTap), for: .touchUpInside)
    }

    private func refreshDeleteButton(isDeleting: Bool) {
        btnDelete.backgroundColor = isDeleting ?
            UIColor.blue :
            UIColor.white
    }

    @IBAction private func btnDeleteOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.isDeleting.toggle()
    }
}
