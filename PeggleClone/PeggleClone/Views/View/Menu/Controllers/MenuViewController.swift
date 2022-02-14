import UIKit

class MenuViewController: UIViewController, Storyboardable {
    @IBOutlet private var btnDesigner: UIButton!
    @IBOutlet private var btnLevelSelect: UIButton!

    var didSelectDesigner: (() -> Void)?
    var didSelectLevelSelect: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerEventHandlers()
    }
}

// MARK: Setup
extension MenuViewController {
    private func registerEventHandlers() {
        btnDesigner.addTarget(self, action: #selector(btnDesignerOnTap), for: .touchUpInside)
        btnLevelSelect.addTarget(self, action: #selector(btnLevelSelectOnTap), for: .touchUpInside)
    }
}

// MARK: Event handlers
extension MenuViewController {
    @IBAction private func btnDesignerOnTap() {
        didSelectDesigner?()
    }

    @IBAction private func btnLevelSelectOnTap() {
        didSelectLevelSelect?()
    }
}
