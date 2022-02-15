import UIKit
import Combine

// reference: cocoacasts
class AppCoordinator {
    private var navigationController = UINavigationController()

    var rootViewController: UIViewController {
        navigationController
    }
    
    var subscriptions: Set<AnyCancellable> = []

    var loadLevelURL: URL?
    var selectedPeggleMaster: PeggleMaster?

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
        let vcLevelSelect = LevelSelectCollectionViewController.instantiate()
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

        vcLevelSelect.tabBarItem = UITabBarItem(title: "Levels", image: nil, tag: 0)

        let vcPeggleMaster = PeggleMasterCollectionViewController.instantiate()
        let vmPeggleMaster = PeggleMasterViewModel(selectedPeggleMaster: selectedPeggleMaster)
        vcPeggleMaster.viewModel = vmPeggleMaster
        
        vmPeggleMaster.$selectedPeggleMaster
            .assign(to: \.selectedPeggleMaster, on: self)
            .store(in: &subscriptions)

        vcPeggleMaster.tabBarItem = UITabBarItem(title: "Players", image: nil, tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([vcLevelSelect, vcPeggleMaster], animated: true)

        navigationController.pushViewController(tabBarController, animated: true)
    }

    private func showGame(with backingDesignerGameLevel: PersistableDesignerGameLevel) {
        let vcGame = GameViewController.instantiate()
        let vmGame = GameViewModel(peggleMaster: selectedPeggleMaster)
        vmGame.backingDesignerGameLevel = backingDesignerGameLevel
        vcGame.viewModel = vmGame

        vcGame.didBackToLevelSelect = { [weak self] in
            guard let self = self else {
                return
            }
            let vcLevelSelect: LevelSelectCollectionViewController? = self.navigationController
                .viewControllers
                .first { $0 is LevelSelectCollectionViewController }
                as? LevelSelectCollectionViewController
            if let vcLevelSelect = vcLevelSelect {
                self.navigationController.popToViewController(vcLevelSelect, animated: true)
            } else {
                self.showLevelSelect()
            }
        }

        navigationController.pushViewController(vcGame, animated: true)
    }
}
