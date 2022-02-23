import UIKit
import Combine

protocol DesignerLayoutViewModelDelegate: AnyObject, CoordinateMappable {
    var gameLevel: DesignerGameLevel? { get }
}

class DesignerLayoutViewModel {
    weak var delegate: DesignerLayoutViewModelDelegate? {
        didSet {
            setupBindingsWithDelegate()
        }
    }
    private var subscriptions: Set<AnyCancellable> = []
    var displayDimensionsPublisher: AnyPublisher<CGRect, Never> {
        displayDimensions.eraseToAnyPublisher()
    }
    var displayDimensions: PassthroughSubject<CGRect, Never> = PassthroughSubject()
    var pegZonePublisher: AnyPublisher<CGRect, Never> {
        pegZone.eraseToAnyPublisher()
    }
    var pegZone: PassthroughSubject<CGRect, Never> = PassthroughSubject()

    private func setupBindingsWithDelegate() {
        guard let delegate = delegate else {
            return
        }
        guard let gameLevel = delegate.gameLevel else {
            return
        }

        gameLevel.$playArea.sink { [weak self] playArea in
            guard let self = self else {
                return
            }
            let boundingBox = playArea.pegZoneBoundingBox
            let topLeft = delegate.getDisplayCoords(of: boundingBox.topLeft)
            self.displayDimensions.send(CGRect(
                x: 0,
                y: 0,
                width: gameLevel.coordinateMapper.displayWidth,
                height: gameLevel.coordinateMapper.displayHeight
            ))
            self.pegZone.send(CGRect(
                x: topLeft.x,
                y: topLeft.y,
                width: delegate.getDisplayLength(of: boundingBox.width),
                height: delegate.getDisplayLength(of: boundingBox.height)
            ))
        }
        .store(in: &subscriptions)

    }
}
