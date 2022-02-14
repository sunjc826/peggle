import UIKit

extension UIView {

    // reference: https://stackoverflow.com/questions/21370728/rotate-uiview-around-its-center-keeping-its-size
    func rotate(radians: CGFloat) {
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }

}
