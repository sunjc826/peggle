import Foundation
import CoreGraphics

enum GameEvent {
    case ballCollision
    case ballFallthrough
    case ballWrapAround
    case ballMultiply
    case ballIntoBucket
    case specialPegHit(location: CGPoint)
    case gravityLowered
    case nothingHit
}
