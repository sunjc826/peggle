import Foundation
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
        static let uniformDensity: Double = 20
        static let elasticity: Double = 0.7
    }

    struct Peg {
        static let uniformDensity: Double = 1
        static let elasticity: Double = 0.7
        static let canTranslate = false
        struct Polygonal {
            static let canRotate = true
        }
    }

    struct Cannon {
        static let defaultEjectionSpeed: Double = 0.20
    }
}
// swiftlint:enable nesting
