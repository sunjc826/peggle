import UIKit

extension DesignerViewController {
    func addGameObjectChild(gameObject: GameObject) {
        switch gameObject {
        case let peg as Peg:
            addPegChild(peg: peg)
        case let obstacle as Obstacle:
            addObstacleChild(obstacle: obstacle)
        default:
            fatalError("unexpected type")
        }
    }

    func addObstacleChild(obstacle: Obstacle) {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let vmObstacle = viewModel.getDesignerObstacleViewModel(obstacle: obstacle)
        let btnDesignerObstacle = DesignerObstacleButton(
            viewModel: vmObstacle,
            delegate: self
        )
        btnDesignerObstacle.translatesAutoresizingMaskIntoConstraints = true
        vLayout.addSubview(btnDesignerObstacle)
        obstacleToButtonMap[obstacle] = btnDesignerObstacle
    }

    func addPegChild(peg: Peg) {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let vmPeg = viewModel.getDesignerPegViewModel(peg: peg)
        let btnDesignerPeg = DesignerPegButton(
            viewModel: vmPeg,
            delegate: self
        )
        btnDesignerPeg.translatesAutoresizingMaskIntoConstraints = true
        vLayout.addSubview(btnDesignerPeg)
        pegToButtonMap[peg] = btnDesignerPeg
    }

    func updateGameObjectChild(oldGameObject: GameObject, updatedGameObject: GameObject) {
        switch (oldGameObject, updatedGameObject) {
        case let (oldPeg as Peg, updatedPeg as Peg):
            updatePegChild(oldPeg: oldPeg, updatedPeg: updatedPeg)
        case let (oldObstacle as Obstacle, updatedObstacle as Obstacle):
            updateObstacleChild(oldObstacle: oldObstacle, updatedObstacle: updatedObstacle)
        default:
            fatalError("unexpected type")
        }
    }

    func updateObstacleChild(oldObstacle: Obstacle, updatedObstacle: Obstacle) {
        guard let btnDesignerObstacle = obstacleToButtonMap[oldObstacle] else {
            fatalError("should not be nil")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        obstacleToButtonMap[oldObstacle] = nil
        obstacleToButtonMap[updatedObstacle] = btnDesignerObstacle
        btnDesignerObstacle.viewModel = viewModel.getDesignerObstacleViewModel(obstacle: updatedObstacle)
        viewModel.selectToEdit(viewModel: btnDesignerObstacle.viewModel)
    }

    func updatePegChild(oldPeg: Peg, updatedPeg: Peg) {
        guard let btnDesignerPeg = pegToButtonMap[oldPeg] else {
            fatalError("Peg should be associated with a button")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        pegToButtonMap[oldPeg] = nil
        pegToButtonMap[updatedPeg] = btnDesignerPeg
        btnDesignerPeg.viewModel = viewModel.getDesignerPegViewModel(peg: updatedPeg)
        viewModel.selectToEdit(viewModel: btnDesignerPeg.viewModel)
    }

    func removeGameObjectChild(gameObject: GameObject) {
        switch gameObject {
        case let peg as Peg:
            removePegChild(peg: peg)
        case let obstacle as Obstacle:
            removeObstacleChild(obstacle: obstacle)
        default:
            fatalError("unexpected type")
        }
    }

    func removeObstacleChild(obstacle: Obstacle) {
        guard let btnDesignerObstacle = obstacleToButtonMap[obstacle] else {
            fatalError("should not be nil")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        btnDesignerObstacle.removeFromSuperview()
        obstacleToButtonMap[obstacle] = nil
    }

    func removePegChild(peg: Peg) {
        guard let btnDesignerPeg = pegToButtonMap[peg] else {
            fatalError("Peg should be found in map")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        btnDesignerPeg.removeFromSuperview()
        pegToButtonMap[peg] = nil
    }

    func clearGameObjects() {
        pegToButtonMap.values.forEach {
            $0.removeFromSuperview()
        }
        pegToButtonMap.removeAll()
        
        obstacleToButtonMap.values.forEach {
            $0.removeFromSuperview()
        }
        obstacleToButtonMap.removeAll()
    }
}
