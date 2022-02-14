import UIKit

// reference: cocoacasts
class AppCoordinator {
    private var navigationController = UINavigationController()

    var rootViewController: UIViewController {
        navigationController
    }

    var loadLevelURL: URL?

    func start() {
        showMenu()
    }

    private func showMenu() {
        let vcMenu = MenuViewController.instantiate()
        vcMenu.didSelectDesigner = { [weak self] in
            guard let self = self else {
                return
            }

            self.loadLevelURL = nil
            self.showDesigner()
        }

        vcMenu.didSelectLevelSelect = { [weak self] in
            guard let self = self else {
                return
            }

            self.showLevelSelect()
        }

        navigationController.pushViewController(vcMenu, animated: true)
    }

    private func showDesigner() {
        let vcDesignerMain = DesignerMainViewController.instantiate()
        let vmDesignerMain = DesignerMainViewModel()
        vcDesignerMain.viewModel = vmDesignerMain
        vcDesignerMain.didLevelSelect = { [weak self, vmDesignerMain] in
            guard let self = self else {
                return
            }
            vmDesignerMain.tearDownBeforeTransition()
            self.showLevelSelect()
        }

        vcDesignerMain.didStartGame = { [weak self, vmDesignerMain] in
            guard let self = self else {
                return
            }

            guard let persistableDesignerGameLevel = vmDesignerMain.decodedGameLevel else {
                return
            }

            vmDesignerMain.tearDownBeforeTransition()
            self.showGame(with: persistableDesignerGameLevel)
        }

        vcDesignerMain.didStartOwnView = { [weak self, vmDesignerMain] in
            guard let self = self, let loadLevelURL = self.loadLevelURL else {
                return
            }

            vmDesignerMain.loadLevel(url: loadLevelURL)
        }

        navigationController.pushViewController(vcDesignerMain, animated: true)
    }

    private func showLevelSelect() {
        loadLevelURL = nil
        let vcLevelSelect = LevelSelectViewController.instantiate()
        let vmLevelSelect = LevelSelectViewModel()
        vcLevelSelect.viewModel = vmLevelSelect

        vcLevelSelect.didLoadLevel = { [weak self] loadLevelURL in
            guard let self = self else {
                return
            }
            self.loadLevelURL = loadLevelURL
            let vcDesignerMain: DesignerMainViewController? = self.navigationController
                .viewControllers
                .first { $0 is DesignerMainViewController }
                as? DesignerMainViewController
            if let vcDesignerMain = vcDesignerMain {
                self.navigationController.popToViewController(vcDesignerMain, animated: true)
            } else {
                self.showDesigner()
            }
        }

        vcLevelSelect.didStartLevel = { [weak self] startLevelURL in
            guard let self = self else {
                return
            }
            let vmDesignerMain = DesignerMainViewModel()
            vmDesignerMain.loadLevel(url: startLevelURL)
            guard let gameLevel = vmDesignerMain.decodedGameLevel else {
                return
            }
            self.showGame(with: gameLevel)
        }

        navigationController.pushViewController(vcLevelSelect, animated: true)
    }

    private func showGame(with backingDesignerGameLevel: PersistableDesignerGameLevel) {
        let vcGame = GameViewController.instantiate()
        let vmGame = GameViewModel()
        vmGame.backingDesignerGameLevel = backingDesignerGameLevel
        vcGame.viewModel = vmGame
        navigationController.pushViewController(vcGame, animated: true)
    }
}
