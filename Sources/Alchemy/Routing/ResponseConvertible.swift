/// Represents any type that can be converted into a response & is
/// thus returnable from a request handler.
public protocol ResponseConvertible {
    /// Takes the type and turns it into a `Response`.
    ///
    /// - Throws: Any error that might occur when this is turned into
    ///   a `Response`.
    /// - Returns: A `Response` to respond to a `Request` with.
    func response() async throws -> Response
}

// MARK: Convenient `ResponseConvertible` Conformances.

extension Response: ResponseConvertible {
    public func response() -> Response {
        self
    }
}

extension String: ResponseConvertible {
    public func response() -> Response {
        Response(status: .ok).withString(self)
    }
}

// Sadly `Swift` doesn't allow a protocol to conform to another
// protocol in extensions, but we can at least add the
// implementation here (and a special case router
// `.on` specifically for `Encodable`) types.
extension Encodable {
    public func response() throws -> Response {
        try Response(status: .ok).withValue(self)
    }
}
