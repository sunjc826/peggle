import os

/// A wrapper over the logger class. This allows for setting the current log level, so that any logs of a lower
/// level than the current log level will not be logged.
/// For simplicity, only 3 log levels are used, namely `debug`, `info` and `error`
/// (in ascending order of severity).
///
/// Example:
/// 1. Suppose we only want to log messages above info, so that info and error logs are logged, but debug logs are not.
///  ```
/// var logger = LoggerWrapper()
/// logger.logLevel = .info
/// logger.debug("debug") // this is ignored
/// logger.info("info") // logs "info"
/// logger.error("error") // logs "error"
/// ```
class LoggerWrapper {
    enum LogLevel: Int, Comparable {
        static func < (lhs: LoggerWrapper.LogLevel, rhs: LoggerWrapper.LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case debug = 0
        case info
        case error
    }

    private var logger = Logger()

    fileprivate init() {}

    /// The current severity level of the logger.
    var logLevel: LogLevel = .debug

    func debug(_ message: String) {
        if logLevel <= .debug {
            logger.debug("\(message)")
        }
    }

    func info(_ message: String) {
        if logLevel <= .info {
            logger.info("\(message)")
        }
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }
}

/// Global logger object for the application.
let globalLogger = LoggerWrapper()
