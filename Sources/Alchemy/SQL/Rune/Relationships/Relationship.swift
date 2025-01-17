import NIO

/// A protocol representing a relationship between two `Model`s.
/// Contains only those two types and functionality for eager
/// loading this relationship.
public protocol Relationship {
    /// The `From` model from the perspective of this relationship.
    /// Likely the type that the `Relationship` is a property on.
    associatedtype From: Model
    
    /// The `To` model from the perspective of this relationship.
    /// Likely the type that the `Relationship` is _not_ a
    /// property on.
    associatedtype To: RelationshipAllowed
    
    associatedtype Wrapped
    
    var wrappedValue: Wrapped { get }
    
    func set(values: [To]) throws
    
    static func defaultConfig() -> RelationshipMapping<From, To.Value>
}

/// Either a `Model` or a `Model?`.
///
/// This protocol exists so that `Model?` and `Model` can be treated
/// similarly in relationship property wrappers. Sometimes a
/// relationship may be optional, sometimes it may be
/// required. Alchemy supports both cases.
public protocol RelationshipAllowed {
    /// The underlying `Model` type. `Self` if this is a `Model`,
    /// `Wrapped` if this is a `Model?`.
    associatedtype Value: Model
    
    /// Given an optional object of type `Value`, convert that to this
    /// type. Used for managing the type system when putting eagerly
    /// loaded data into relationship properties.
    ///
    /// - Parameter value: The value to convert.
    /// - Throws: An error if the optional value was unable to be
    ///   converted to `Self`.
    /// - Returns: The `value` converted to type `Self`.
    static func from(_ value: Value?) throws -> Self
    
    static func from(_ value: Self?) throws -> Self
    
    var id: Value.Identifier? { get }
}

// MARK: RelationshipAllowed

extension Model {
    public static func from(_ value: Self?) throws -> Self {
        try value.unwrap(or: RuneError.relationshipWasNil(type: Self.self))
    }
}

extension Optional: RelationshipAllowed where Wrapped: Model {
    public static func from(_ value: Optional<Wrapped>?) throws -> Optional<Wrapped> {
        value ?? nil
    }
    
    public static func from(_ value: Wrapped?) throws -> Self {
        value
    }
    
    public var id: Wrapped.Identifier? {
        map(\.id) ?? nil
    }
}
