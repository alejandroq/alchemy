import Crypto
import Foundation

extension HashAlgorithm where Self == SHA256Hasher {
    public static var sha256: SHA256Hasher {
        SHA256Hasher()
    }
}

public final class SHA256Hasher: HashAlgorithm {
    fileprivate var sha256 = SHA256()
    
    public func update<D: DataProtocol>(_ value: D) {
        sha256.update(data: value)
    }
    
    public func digest() -> String {
        sha256.finalize().description
    }
    
    public func verify(_ plaintext: String, hash: String) -> Bool {
        make(plaintext) == hash
    }
    
    public func make(_ value: String) -> String {
        update(Data(value.utf8))
        return digest()
    }
}

extension Hasher where Algorithm == SHA256Hasher {
    public func update(_ value: String) {
        algorithm.update(Data(value.utf8))
    }
    
    public func update<D: DataProtocol>(_ data: D) {
        algorithm.update(data)
    }
    
    public func digest() -> String {
        algorithm.digest()
    }
}
