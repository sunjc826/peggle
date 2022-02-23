import UIKit
import Combine

protocol LevelSelectCellDelegate: AnyObject {
    func onLoadLevel(levelURL: URL)
    func onStartLevel(levelURL: URL)
}

/// Encapsulates a single cell displayed in the level select collection.
/// A cell holds information regarding a single game level stored locally.
class LevelSelectCell: UICollectionViewCell {
    @IBOutlet private var lblLevelName: UILabel!
    @IBOutlet private var btnLoad: UIButton!
    @IBOutlet private var btnStart: UIButton!
    @IBOutlet private var btnDelete: UIButton!
    @IBOutlet private var ivLevelImage: UIImageView!

    weak var delegate: LevelSelectCellDelegate?
    var viewModel: LevelSelectCellViewModel? {
        didSet {
            setupWithViewModel()
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    func setupWithViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.isPreloaded {
            btnLoad.removeFromSuperview()
            btnDelete.removeFromSuperview()
        } else {
            btnDelete.setTitle("\u{1f5d1}", for: .normal)
        }
        setupBindings()
        registerEventHandlers()
    }
}

// MARK: Setup
extension LevelSelectCell {
    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$text
            .assign(to: \.text, on: lblLevelName)
            .store(in: &subscriptions)

        viewModel.$backgroundImage
            .compactMap { $0 }
            .assign(to: \.image, on: ivLevelImage)
            .store(in: &subscriptions)
    }

    private func registerEventHandlers() {
        guard let viewModel = viewModel else {
            return
        }

        btnStart.addTarget(self, action: #selector(btnStartOnTap), for: .touchUpInside)
        guard !viewModel.isPreloaded else {
            return
        }
        btnLoad.addTarget(self, action: #selector(btnLoadOnTap), for: .touchUpInside)
        btnDelete.addTarget(self, action: #selector(btnDeleteOnTap), for: .touchUpInside)
    }
}

// MARK: Event handlers
extension LevelSelectCell {
    @IBAction private func btnLoadOnTap() {
        guard let delegate = delegate, let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        delegate.onLoadLevel(levelURL: viewModel.levelURL)
    }

    @IBAction private func btnStartOnTap() {
        guard let delegate = delegate, let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        delegate.onStartLevel(levelURL: viewModel.levelURL)
    }

    @IBAction private func btnDeleteOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.delete()
    }
}
