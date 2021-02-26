import Foundation

public protocol Default {
    associatedtype Value

    static var defaultValue: Value { get }
}

@propertyWrapper
public struct DefaultDecodable<D: Default>: Decodable where D.Value: Decodable {
    public let wrappedValue: D.Value

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(D.Value.self)
    }

    public init() {
        wrappedValue = D.defaultValue
    }
}

public extension KeyedDecodingContainer {
    func decode<D>(_ type: DefaultDecodable<D>.Type,
                   forKey key: Key) throws -> DefaultDecodable<D> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public protocol EmptyInitializable {
    init()
}

extension String: EmptyInitializable {}

extension Array: EmptyInitializable {}

public protocol SelfDefault: Default {
    static var defaultValue: Self { get }
}

public enum CommonDefault {
    public struct `Self`<Value: SelfDefault>: Default {
        public static var defaultValue: Value {
            Value.defaultValue
        }
    }

    public struct Empty<Value: EmptyInitializable>: Default {
        public static var defaultValue: Value {
            .init()
        }
    }

    public struct Zero<Value: Numeric>: Default {
        public static var defaultValue: Value {
            .zero
        }
    }

    public struct One<Value: Numeric>: Default {
        public static var defaultValue: Value {
            1
        }
    }

    public struct MinusOne<Value: Numeric>: Default {
        public static var defaultValue: Value {
            -1
        }
    }
}

public enum DefaultBy {
    public typealias `Self`<Value: Decodable & SelfDefault> = DefaultDecodable<CommonDefault.Self<Value>>

    public typealias Empty<Value: Decodable & EmptyInitializable> = DefaultDecodable<CommonDefault.Empty<Value>>

    public typealias Zero<Value: Decodable & Numeric> = DefaultDecodable<CommonDefault.Zero<Value>>

    public typealias One<Value: Decodable & Numeric> = DefaultDecodable<CommonDefault.One<Value>>

    public typealias MinusOne<Value: Decodable & Numeric> = DefaultDecodable<CommonDefault.MinusOne<Value>>
}
