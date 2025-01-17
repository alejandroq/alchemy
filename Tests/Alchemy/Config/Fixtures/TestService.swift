import Alchemy

struct TestService: Service, Configurable {
    public struct Identifier: ServiceIdentifier {
        private let hashable: AnyHashable
        public init(hashable: AnyHashable) { self.hashable = hashable }
    }
    
    struct Config {
        let foo: String
    }

    static var config = Config(foo: "baz")
    static var foo: String = "bar"
    
    let bar: String
    
    static func configure(with config: Config) {
        foo = config.foo
    }
}

extension TestService.Identifier {
    static var foo: Self { "foo" }
}
