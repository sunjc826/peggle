import Foundation

enum GameEvent {
    case ballCollision
    case ballFallthrough
    case ballWrapAround
    case ballMultiply
    case ballIntoBucket
    case specialPegHit
    case gravityLowered
    case nothingHit
}
