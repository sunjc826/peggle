import UIKit
class GameplayAreaView: UIView {
    var viewModel: GameplayAreaViewModel?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let viewModel = viewModel else {
            return
        }

        guard viewModel.shouldDrawPrediction else {
            return
        }

        let positions = viewModel.predictiveLinePoints
        guard !positions.isEmpty else {
            return
        }

        let path = UIBezierPath()
        UIColor.black.setStroke()
        path.lineWidth = 3
        path.setLineDash([7, 3], count: 2, phase: 0)
        path.move(to: positions[0])
        for i in 1..<positions.count {
            path.addLine(to: positions[i])
        }
        path.stroke()
    }
}
