public final class StubDatabase: DatabaseProvider {
    private var isShutdown = false
    private var stubs: [[SQLRow]] = []
    
    public let grammar = Grammar()
    
    init() {}
    
    public func query(_ sql: String, values: [SQLValue]) async throws -> [SQLRow] {
        guard !isShutdown else {
            throw StubDatabaseError("This stubbed database has been shutdown.")
        }
        
        guard let mockedRows = stubs.first else {
            throw StubDatabaseError("Before running a query on a stubbed database, please stub it's resposne with `stub()`.")
        }
        
        return mockedRows
    }
    
    public func raw(_ sql: String) async throws -> [SQLRow] {
        try await query(sql, values: [])
    }
    
    public func transaction<T>(_ action: @escaping (DatabaseProvider) async throws -> T) async throws -> T {
        try await action(self)
    }
    
    public func shutdown() throws {
        isShutdown = true
    }
    
    public func stub(_ rows: [StubDatabaseRow]) {
        stubs.append(rows)
    }
}

public struct StubDatabaseRow: SQLRow {
    public let data: [String: SQLValueConvertible]
    public let columns: Set<String>
    
    public init(data: [String: SQLValueConvertible] = [:]) {
        self.data = data
        self.columns = Set(data.keys)
    }
    
    public func get(_ column: String) throws -> SQLValue {
        try data[column].unwrap(or: StubDatabaseError("Stubbed database row had no column `\(column)`.")).value
    }
}

/// An error encountered when interacting with a `StubDatabase`.
public struct StubDatabaseError: Error {
    /// What went wrong.
    let message: String
    
    /// Initialize a `DatabaseError` with a message detailing what
    /// went wrong.
    ///
    /// - Parameter message: Why this error was thrown.
    init(_ message: String) {
        self.message = message
    }
}