import Foundation
import NIO
import NIOHTTP1
import Hummingbird

/// A type that represents inbound requests to your application.
public final class Request: RequestInspector {
    /// The request body.
    public var body: ByteContent? { hbRequest.byteContent }
    /// The byte buffer of this request's body, if there is one.
    public var buffer: ByteBuffer? { body?.buffer }
    /// The stream of this request's body, if there is one.
    public var stream: ByteStream? { body?.stream }
    /// The remote address where this request came from.
    public var remoteAddress: SocketAddress? { hbRequest.remoteAddress }
    /// The remote address where this request came from.
    public var ip: String { remoteAddress?.ipAddress ?? "" }
    /// The event loop this request is being handled on.
    public var loop: EventLoop { hbRequest.eventLoop }
    /// The HTTPMethod of the request.
    public var method: HTTPMethod { hbRequest.method }
    /// Any headers associated with the request.
    public var headers: HTTPHeaders { hbRequest.headers }
    /// The complete url of the request.
    public var url: URL { urlComponents.url ?? URL(fileURLWithPath: "") }
    /// The path of the request. Does not include the query string.
    public var path: String { urlComponents.path }
    /// Any query items parsed from the URL. These are not percent encoded.
    public var queryItems: [URLQueryItem]? { urlComponents.queryItems }
    /// The underlying hummingbird request
    public var hbRequest: HBRequest
    /// Allows for extending storage on this type.
    public var extensions: Extensions<Request>
    /// The url components of this request.
    public let urlComponents: URLComponents
    /// Parameters parsed from the path.
    public var parameters: [Parameter] {
        get { extensions.get(\.parameters) }
        set { extensions.set(\.parameters, value: newValue) }
    }
    
    init(hbRequest: HBRequest, parameters: [Parameter] = []) {
        self.hbRequest = hbRequest
        self.urlComponents = URLComponents(string: hbRequest.uri.string) ?? URLComponents()
        self.extensions = Extensions()
        self.parameters = parameters
    }
    
    public func parameter<L: LosslessStringConvertible>(_ key: String, as: L.Type = L.self) -> L? {
        parameters.first(where: { $0.key == key }).map { L($0.value) } ?? nil
    }
    
    /// Returns the first parameter for the given key, if there is one.
    ///
    /// Use this to fetch any parameters from the path.
    /// ```swift
    /// app.post("/users/:user_id") { request in
    ///     let userId: Int = try request.parameter("user_id")
    ///     ...
    /// }
    /// ```
    public func parameter<L: LosslessStringConvertible>(_ key: String, as: L.Type = L.self) throws -> L {
        guard let parameterString: String = parameters.first(where: { $0.key == key })?.value else {
            throw ValidationError("expected parameter \(key)")
        }
        
        guard let converted = L(parameterString) else {
            throw ValidationError("parameter \(key) was \(parameterString) which couldn't be converted to \(name(of: L.self))")
        }
        
        return converted
    }
}

extension HBRequest {
    fileprivate var byteContent: ByteContent? {
        switch body {
        case .byteBuffer(let bytes):
            return bytes.map { .buffer($0) }
        case .stream(let streamer):
            return .stream(streamer.byteStream(eventLoop))
        }
    }
}

extension HBStreamerProtocol {
    func byteStream(_ loop: EventLoop) -> ByteStream {
        return .new { reader in
            try await self.consumeAll(on: loop) { buffer in
                return loop.asyncSubmit { try await reader.write(buffer) }
            }.get()
        }
    }
}
