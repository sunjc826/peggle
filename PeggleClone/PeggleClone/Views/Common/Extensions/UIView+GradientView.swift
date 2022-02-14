import UIKit
// reference: https://stackoverflow.com/questions/68452962/ios-draw-a-view-with-gradient-background
// extensions with methods extracted from GradientProgressView
extension UIView {
    func drawGradient(path: UIBezierPath, gradient: CGGradient, context: CGContext) {
        context.saveGState()

        path.addClip() // This will be discarded once restoreGState() is called
        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            startRadius: 0.0,
            endCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            endRadius: min(bounds.width, bounds.height), options: []
        )

        context.restoreGState()
    }

    func drawLine(path: UIBezierPath, lineWidth: CGFloat, context: CGContext) {
        UIColor.black.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}
