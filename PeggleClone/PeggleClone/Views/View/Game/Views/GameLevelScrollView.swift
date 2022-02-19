import UIKit

class GameLevelScrollView: UIScrollView {
    var vGame: GameplayAreaDynamicView

    override init(frame: CGRect) {
        vGame = GameplayAreaDynamicView(frame: frame)
        super.init(frame: frame)
        isScrollEnabled = false

        vGame.frame = bounds
        addSubview(vGame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
