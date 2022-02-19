import UIKit

extension DesignerViewController {
    func addLetterBoxes() {
        guard let scrollvLayout = scrollvLayout else {
            fatalError("should not be nil")
        }

        let vLetterBoxes = view.getLetterBoxes(around: scrollvLayout)
        self.vLetterBoxes.append(contentsOf: vLetterBoxes)
        for vLetterBox in self.vLetterBoxes {
            view.addSubview(vLetterBox)
            view.sendSubviewToBack(vLetterBox)
        }
    }
}
