import UIKit
import Combine

class GenericStatView: UIStackView {
    var viewModel: GenericStatViewModel
    private var subscriptions: Set<AnyCancellable> = []

    private let lblKey = UILabel()
    private let lblValue = UILabel()

    init(viewModel: GenericStatViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.lblKey.text = viewModel.key
        addArrangedSubview(lblKey)
        addArrangedSubview(lblValue)
        setupBindings()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GenericStatView {
    private func setupBindings() {
        viewModel.value
            .compactMap { $0 }
            .assign(to: \.text, on: lblValue)
            .store(in: &subscriptions)
    }
}
