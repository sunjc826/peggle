import Foundation

enum GamePhase {
    case beginning // No instruction to shoot ball has been given.
    case shootBallWhenReady // Instruction to shoot ball has been given.
    case ongoing // Ball has been shot.
    case stuck // Ball is stuck.
    case cleanup // Cleaning up pegs that have been hit.
    case waitingForNewRound // Similar to disabled, but allows physics updates to occur.
    case gameEnd(stats: GameRoundStats) // Player has either won or lost.
    case disabled // Game is disabled and does not respond to external input.
}

extension GamePhase: Equatable {}
