import UIKit

extension UIView {
    func getLetterBoxes(around childView: UIView) -> [LetterBoxView] {
        var vLetterBoxes: [LetterBoxView] = []

        let frameLeft = frame.minX
        let frameRight = frame.maxX
        let frameTop = frame.minY
        let frameBottom = frame.maxY
        let childLeft = childView.frame.minX
        let childRight = childView.frame.maxX
        let childTop = childView.frame.minY
        let childBottom = childView.frame.maxY

        // letterboxes on left and right
        if childView.frame.width < frame.width {
            let vLeftLetterBox = LetterBoxView()
            let vRightLetterBox = LetterBoxView()
            vLeftLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: childLeft - frameLeft,
                height: frameBottom - frameTop
            )
            vRightLetterBox.frame = CGRect(
                x: childRight, y: frameTop,
                width: frameRight - childRight,
                height: frameBottom - frameTop
            )
            vLetterBoxes.append(vLeftLetterBox)
            vLetterBoxes.append(vRightLetterBox)
        }

        // letterboxes on top and bottom
        if childView.frame.height < frame.height {
            let vTopLetterBox = LetterBoxView()
            let vBottomLetterBox = LetterBoxView()
            vTopLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: frameRight - frameLeft,
                height: childTop - frameTop
            )
            vBottomLetterBox.frame = CGRect(
                x: frameLeft, y: childBottom,
                width: frameRight - frameLeft,
                height: frameBottom - childBottom
            )
            vLetterBoxes.append(vTopLetterBox)
            vLetterBoxes.append(vBottomLetterBox)
        }

        return vLetterBoxes
    }
}
