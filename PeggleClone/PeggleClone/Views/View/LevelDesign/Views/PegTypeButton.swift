import UIKit
import Combine

class PegTypeButton: UIButton {
    var viewModel: PegTypeButtonViewModel
    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: PegTypeButtonViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        addTarget(self, action: #selector(self.onTap), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = viewModel.color
        setTitle(viewModel.text, for: .normal)
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PegTypeButton {
    private func setupBindings() {
        viewModel.$isSelected
            .sink { [weak self] in
                guard let self = self else {
                    return
                }

                if $0 {
                    self.isEnabled = false
                } else {
                    self.isEnabled = true
                }
            }
            .store(in: &subscriptions)
    }
}

extension PegTypeButton {
    @IBAction private func onTap() {
        viewModel.select()
    }
}
