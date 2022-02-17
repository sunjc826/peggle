import UIKit

extension DesignerViewController {
    func addLetterBoxes(displayDimensions: CGRect) {
        guard let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let frameLeft = self.view.frame.minX
        let frameRight = self.view.frame.maxX
        let frameTop = self.view.frame.minY
        let frameBottom = self.view.frame.maxY
        let vLayoutLeft = vLayout.frame.minX
        let vLayoutRight = vLayout.frame.maxX
        let vLayoutTop = vLayout.frame.minY
        let vLayoutBottom = vLayout.frame.maxY
        // letterboxes on left and right
        if displayDimensions.width < self.view.frame.width {
            let vLeftLetterBox = LetterBoxView()
            let vRightLetterBox = LetterBoxView()
            vLeftLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: vLayoutLeft - frameLeft,
                height: frameBottom - frameTop
            )
            vRightLetterBox.frame = CGRect(
                x: vLayoutRight, y: frameTop,
                width: frameRight - vLayoutRight,
                height: frameBottom - frameTop
            )
            self.vLetterBoxes.append(vLeftLetterBox)
            self.vLetterBoxes.append(vRightLetterBox)
        }

        // letterboxes on top and bottom
        if displayDimensions.height < self.view.frame.height {
            let vTopLetterBox = LetterBoxView()
            let vBottomLetterBox = LetterBoxView()
            vTopLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: frameRight - frameLeft,
                height: vLayoutTop - frameTop
            )
            vBottomLetterBox.frame = CGRect(
                x: frameLeft, y: vLayoutBottom,
                width: frameRight - frameLeft,
                height: frameBottom - vLayoutBottom
            )
            self.vLetterBoxes.append(vTopLetterBox)
            self.vLetterBoxes.append(vBottomLetterBox)
        }

        for vLetterBox in self.vLetterBoxes {
            self.view.addSubview(vLetterBox)
            self.view.sendSubviewToBack(vLetterBox)
        }
    }
}
