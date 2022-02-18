import UIKit

// This file consists of constants, hence deep levels of nesting are accepted.
// swiftlint:disable nesting
struct Settings {
    enum EaseOfRotation: Double {
        case insanelyStiff = 0
        case stiff = 1.0
        case spinny = 200.0
        case ludicrouslySpinny = 500.0
    }

    static let easeOfRotation: EaseOfRotation = .spinny

    struct Ball {
        static let uniformDensity: Double = 1
        static let elasticity: Double = 0.7
    }

    enum Springiness: Double {
        case insanelyStiff = 10.0
        case stiff = 1.0
        case springy = 0.01
        case ludicrouslySpringy = 0.001
    }

    struct Obstacle {
        static let easeOfOscillation: Springiness = .ludicrouslySpringy
        static let uniformDensity: Double = 1
        static let elasticity: Double = 0.7
        static let canTranslate = true
        static let canRotate = true
    }

    struct Peg {
        static let uniformDensity: Double = 1
        static let elasticity: Double = 0.7
        static let canTranslate = false
        struct Polygonal {
            static let canRotate = true
        }

        struct Special {
            static let explosionForceBaseMagnitude: Double = 0.001
            static let explosionRadius: Double = 0.2
            static let attractionForceBaseMagnitude = 0.002
            static let attractionRadius: Double = 0.25
            static let attractionDuration: Double = 1
            static let repulsionForceBaseMagnitude: Double = 0.001
            static let repulsionRadius: Double = 0.2
            static let repulsionDuration: Double = 0.25
            static let multiballEjectionVelocity: Double = 0.35
        }

        struct Color {
            static let compulsory = UIColor.orange
            static let optional = UIColor.blue
            static let special = UIColor.green
            static let scoreMultiplier = UIColor.purple
            static let pegBorder = UIColor.black
            private static let innerColor = UIColor.white.withAlphaComponent(0.9)
            private static let outerColor = UIColor.clear
            static let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [innerColor, outerColor].map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            )!
        }
    }

    struct Cannon {
        static let defaultEjectionSpeed: Double = 0.20
    }

    enum Alpha: Double {
        case opaque = 1.0
        case almostOpaque = 0.7
        case translucent = 0.5
        case almostTransparent = 0.3
        case transparent = 0.0
    }

    struct Physics {
        static let signedMagnitudeOfAccelerationDueToGravity = 10.0
    }
}
// swiftlint:enable nesting
