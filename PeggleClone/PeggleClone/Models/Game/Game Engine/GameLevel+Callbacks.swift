import Foundation

extension GameLevel {
    func registerDidAddBallCallback(callback: @escaping UnaryFunction<Ball>) {
        didAddBallCallbacks.append(callback)
    }

    func registerDidUpdateBallCallback(callback: @escaping BinaryFunction<Ball>) {
        didUpdateBallCallbacks.append(callback)
    }

    func registerDidRemoveBallCallback(callback: @escaping UnaryFunction<Ball>) {
        didRemoveBallCallbacks.append(callback)
    }

    func registerDidAddPegCallback(callback: @escaping UnaryFunction<Peg>) {
        didAddPegCallbacks.append(callback)
    }

    func registerDidUpdatePegCallback(callback: @escaping BinaryFunction<Peg>) {
        didUpdatePegCallbacks.append(callback)
    }

    func registerDidRemovePegCallback(callback: @escaping UnaryFunction<Peg>) {
        didRemovePegCallbacks.append(callback)
    }

    func registerGameDidEndCallback(callback: @escaping UnaryFunction<Bool>) {
        gameDidEndCallbacks.append(callback)
    }
}
