import AsyncHTTPClient
import NIO
import Foundation
import NIOHTTP1

/// The contents of an HTTP request or response.
public struct HTTPBody: ExpressibleByStringLiteral, Equatable {
    /// The default decoder for decoding JSON from an `HTTPBody`.
    public static var defaultJSONDecoder = JSONDecoder()
    /// The default encoder for encoding JSON to an `HTTPBody`.
    public static var defaultJSONEncoder = JSONEncoder()
    /// Used to create new ByteBuffers.
    private static let allocator = ByteBufferAllocator()
    
    /// The binary data in this body.
    public let buffer: ByteBuffer
    /// The content type of the data stored in this body. Used to set the
    /// `content-type` header when sending back a response.
    public let contentType: ContentType?
    
    /// Creates a new body from a binary `NIO.ByteBuffer`.
    ///
    /// - Parameters:
    ///    - buffer: The buffer holding the data in the body.
    ///    - contentType: The content type of data in the body.
    public init(buffer: ByteBuffer, contentType: ContentType? = nil) {
        self.buffer = buffer
        self.contentType = contentType
    }
     
    /// Creates a new body containing the text with content type
    /// `text/plain`.
    ///
    /// - Parameter text: The string contents of the body.
    /// - Parameter contentType: The media type of this text. Defaults to
    ///   `.plainText` ("text/plain").
    public init(text: String, contentType: ContentType = .plainText) {
        var buffer = HTTPBody.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        self.buffer = buffer
        self.contentType = contentType
    }
    
    /// Creates a new body from a binary `Foundation.Data`.
    ///
    /// - Parameters:
    ///   - data: The data in the body.
    ///   - contentType: The content type of the body.
    public init(data: Data, contentType: ContentType? = nil) {
        var buffer = HTTPBody.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        self.buffer = buffer
        self.contentType = contentType
    }
  
    /// Creates a body with a JSON object.
    ///
    /// - Parameters:
    ///   - json: The object to encode into the body.
    ///   - encoder: A customer encoder to encoder the JSON with.
    ///     Defaults to `Response.defaultJSONEncoder`.
    /// - Throws: Any error thrown during encoding.
    public init<E: Encodable>(json: E, encoder: JSONEncoder = HTTPBody.defaultJSONEncoder) throws {
        let data = try encoder.encode(json)
        self.init(data: data, contentType: .json)
    }

    /// Create a body via a string literal.
    ///
    /// - Parameter value: The string literal contents of the body.
    public init(stringLiteral value: String) {
        self.init(text: value)
    }
}

extension HTTPBody {
    /// The contents of this body.
    public func data() -> Data {
        return buffer.withUnsafeReadableBytes { buffer -> Data in
            let buffer = buffer.bindMemory(to: UInt8.self)
            return Data.init(buffer: buffer)
        }
    }
    
    /// Decodes the body as a `String`.
    ///
    /// - Parameter encoding: The `String.Encoding` value to decode
    ///   with. Defaults to `.utf8`.
    /// - Returns: The string decoded from the contents of this body.
    public func decodeString(with encoding: String.Encoding = .utf8) -> String? {
        String(data: data(), encoding: encoding)
    }
    
    /// Decodes the body as a JSON dictionary.
    ///
    /// - Throws: If there's a error decoding the dictionary.
    /// - Returns: The dictionary decoded from the contents of this
    ///   body.
    public func decodeJSONDictionary() throws -> [String: Any]? {
        try JSONSerialization.jsonObject(with: data(), options: []) as? [String: Any]
    }
    
    /// Decodes the body as JSON into the provided Decodable type.
    ///
    /// - Parameters:
    ///   - type: The Decodable type to which the body should be
    ///     decoded.
    ///   - decoder: The Decoder with which to decode. Defaults to
    ///     `Request.defaultJSONEncoder`.
    /// - Throws: Any errors encountered during decoding.
    /// - Returns: The decoded object of type `type`.
    public func decodeJSON<D: Decodable>(as type: D.Type = D.self, with decoder: JSONDecoder = HTTPBody.defaultJSONDecoder) throws -> D {
        return try decoder.decode(type, from: data())
    }
}
