import UIKit
import Combine

class PegStatView: UIStackView {
    var viewModel: PegStatViewModel
    private var subscriptions: Set<AnyCancellable> = []

    private let vPeg: StackPegView
    private let lblCount = UILabel()

    init(viewModel: PegStatViewModel) {
        self.viewModel = viewModel
        vPeg = StackPegView(viewModel: viewModel.stackPegViewModel)
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(vPeg)
        addArrangedSubview(lblCount)
        setupViews()
        setupBindings()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PegStatView {
    private func setupViews() {
        let midYConstraint = vPeg.centerYAnchor.constraint(equalTo: vPeg.superview!.centerYAnchor)
        let heightConstraint = vPeg.heightAnchor.constraint(equalTo: vPeg.superview!.heightAnchor)
        let widthConstraint = vPeg.widthAnchor.constraint(equalTo: vPeg.superview!.heightAnchor)
        midYConstraint.isActive = true
        heightConstraint.isActive = true
        widthConstraint.isActive = true

        setNeedsLayout()
        setNeedsDisplay()
    }

    private func setupBindings() {
        viewModel.count
            .compactMap { $0 }
            .assign(to: \.text, on: lblCount)
            .store(in: &subscriptions)
    }
}
