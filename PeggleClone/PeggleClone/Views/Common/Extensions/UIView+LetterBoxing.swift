import UIKit

extension UIView {
    func getLetterBoxes(around childView: UIView) -> [LetterBoxView] {
        var vLetterBoxes: [LetterBoxView] = []

        let boundsLeft = bounds.minX
        let boundsRight = bounds.maxX
        let boundsTop = bounds.minY
        let boundsBottom = bounds.maxY
        let childLeft = childView.frame.minX
        let childRight = childView.frame.maxX
        let childTop = childView.frame.minY
        let childBottom = childView.frame.maxY

        // letterboxes on left and right
        if childView.frame.width < frame.width {
            let vLeftLetterBox = LetterBoxView()
            let vRightLetterBox = LetterBoxView()
            vLeftLetterBox.frame = CGRect(
                x: boundsLeft, y: boundsTop,
                width: childLeft - boundsLeft,
                height: boundsBottom - boundsTop
            )
            vRightLetterBox.frame = CGRect(
                x: childRight, y: boundsTop,
                width: boundsRight - childRight,
                height: boundsBottom - boundsTop
            )
            vLetterBoxes.append(vLeftLetterBox)
            vLetterBoxes.append(vRightLetterBox)
        }

        // letterboxes on top and bottom
        if childView.frame.height < frame.height {
            let vTopLetterBox = LetterBoxView()
            let vBottomLetterBox = LetterBoxView()
            vTopLetterBox.frame = CGRect(
                x: boundsLeft, y: boundsTop,
                width: boundsRight - boundsLeft,
                height: childTop - boundsTop
            )
            vBottomLetterBox.frame = CGRect(
                x: boundsLeft, y: childBottom,
                width: boundsRight - boundsLeft,
                height: boundsBottom - childBottom
            )
            vLetterBoxes.append(vTopLetterBox)
            vLetterBoxes.append(vBottomLetterBox)
        }

        return vLetterBoxes
    }
}
