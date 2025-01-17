import Logging

/// Convenience struct for logging logs of various levels to a default
/// `Logger`. By default, this logger has label `Alchemy`.
///
/// ```swift
/// Log.debug("Hello, world!")
/// ```
///
/// You can set a custom default logger like so:
/// ```swift
/// // In Application.boot...
/// Log.logger = Logger(label: "my_default_logger")
/// ```
public struct Log {
    /// The logger to which all logs will be logged. By default it's a
    /// logger with label `Alchemy`.
    public static var logger = Logger(label: "Alchemy")
    
    /// Log a message with the `Logger.Level.trace` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func trace(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.trace(.init(stringLiteral: message), metadata: metadata)
    }
    
    /// Log a message with the `Logger.Level.debug` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func debug(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.debug(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Log a message with the `Logger.Level.info` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func info(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.info(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Log a message with the `Logger.Level.notice` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func notice(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.notice(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Log a message with the `Logger.Level.warning` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func warning(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.warning(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Log a message with the `Logger.Level.error` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func error(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.error(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Log a message with the `Logger.Level.critical` log level.
    ///
    /// - Parameters:
    ///   - message: the message to log.
    ///   - metadata: any metadata (a typealias of
    ///     `[String: Logger.MetadataType]`) to log.
    public static func critical(_ message: String, metadata: Logger.Metadata? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        Log.logger.critical(.init(stringLiteral: message), metadata: metadata, file: file, function: function, line: line)
    }
}
