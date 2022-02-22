import UIKit
import Combine
extension DesignerViewController {
    func stopEditingGameObject() {
        guard let viewModel = self.viewModel,
              let previouslyEditedGameObject = viewModel.previouslyEditedGameObject else {
            return
        }

        switch previouslyEditedGameObject {
        case let peg as Peg:
            guard let previouslyEditedPegViewModel = pegToButtonMap[peg]?.viewModel else {
                return
            }
            previouslyEditedPegViewModel.isBeingEdited = false
        case let obstacle as Obstacle:
            guard let previouslyEditedObstacleViewModel = obstacleToButtonMap[obstacle]?.viewModel else {
                return
            }
            previouslyEditedObstacleViewModel.isBeingEdited = false
        default:
            return
        }
    }

    func startEditingGameObject(gameObjectBeingEdited: EditableGameObject?) {
        guard let gameObjectBeingEdited = gameObjectBeingEdited else {
            return
        }
        switch gameObjectBeingEdited {
        case let peg as Peg:
            guard let vmPeg = self.pegToButtonMap[peg]?.viewModel else {
                return
            }
            vmPeg.isBeingEdited = true
        case let obstacle as Obstacle:
            guard let vmObstacle = self.obstacleToButtonMap[obstacle]?.viewModel else {
                return
            }
            vmObstacle.isBeingEdited = true
        default:
            return
        }
    }
}
