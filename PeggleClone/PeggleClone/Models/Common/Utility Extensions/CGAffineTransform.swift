import Foundation
import CoreGraphics

extension CGAffineTransform {
    /// Creates a scale transformation that scales equally in both x and y coords by the given `uniformScale`.
    init(uniformScale: Double) {
        self.init(scaleX: uniformScale, y: uniformScale)
    }

    /// Creates a translation transformation that translates equally in both x and y coords
    /// by the given `uniformTranslation`.
    init(uniformTranslation: Double) {
        self.init(translationX: uniformTranslation, y: uniformTranslation)
    }
}
