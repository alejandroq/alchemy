/// A protocol to which enums on `Model`s should conform to. The enum
/// will be modeled in the backing table by it's raw value.
///
/// Usage:
/// ```swift
/// enum TaskPriority: Int, ModelEnum {
///     case low, medium, high
/// }
///
/// struct Todo: Model {
///     var id: Int?
///     let name: String
///     let isDone: Bool
///     let priority: TaskPriority // Stored as `Int` in the database.
/// }
/// ```
public protocol ModelEnum: AnyModelEnum, CaseIterable {}

/// A type erased `ModelEnum`.
public protocol AnyModelEnum: Codable, SQLValueConvertible {
    init(from sqlValue: SQLValue) throws
    
    /// The default case of this enum. Defaults to the first of
    /// `Self.allCases`.
    static var defaultCase: Self { get }
}

extension ModelEnum {
    public static var defaultCase: Self { Self.allCases.first! }
}

extension AnyModelEnum where Self: RawRepresentable, RawValue == String {
    public init(from sqlValue: SQLValue) throws {
        let string = try sqlValue.string()
        self = try Self(rawValue: string)
            .unwrap(or: DatabaseCodingError("Error decoding \(name(of: Self.self)) from \(string)"))
    }
}

extension AnyModelEnum where Self: RawRepresentable, RawValue == Int {
    public init(from sqlValue: SQLValue) throws {
        let int = try sqlValue.int()
        self = try Self(rawValue: int)
            .unwrap(or: DatabaseCodingError("Error decoding \(name(of: Self.self)) from \(int)"))
    }
}

extension AnyModelEnum where Self: RawRepresentable, RawValue == Double {
    public init(from sqlValue: SQLValue) throws {
        let double = try sqlValue.double()
        self = try Self(rawValue: double)
            .unwrap(or: DatabaseCodingError("Error decoding \(name(of: Self.self)) from \(double)"))
    }
}