import Foundation

extension GameLevel {
    func registerDidAddBallCallback(callback: @escaping CallbackUnaryFunction<Ball>) {
        didAddBallCallbacks.append(callback)
    }

    func registerDidUpdateBallCallback(callback: @escaping CallbackBinaryFunction<Ball>) {
        didUpdateBallCallbacks.append(callback)
    }

    func registerDidRemoveBallCallback(callback: @escaping CallbackUnaryFunction<Ball>) {
        didRemoveBallCallbacks.append(callback)
    }

    func registerDidAddPegCallback(callback: @escaping CallbackUnaryFunction<Peg>) {
        didAddPegCallbacks.append(callback)
    }

    func registerDidUpdatePegCallback(callback: @escaping CallbackBinaryFunction<Peg>) {
        didUpdatePegCallbacks.append(callback)
    }

    func registerDidRemovePegCallback(callback: @escaping CallbackUnaryFunction<Peg>) {
        didRemovePegCallbacks.append(callback)
    }

    func registerGameDidEndCallback(callback: @escaping CallbackUnaryFunction<Bool>) {
        gameDidEndCallbacks.append(callback)
    }
}
