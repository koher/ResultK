public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

extension Result {
    public init(_ value: Value) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
    
    public init(_ value: () throws -> Value) {
        do {
            self = .success(try value())
        } catch let error {
            self = .failure(error)
        }
    }
    
    public var value: Value? {
        switch self {
        case let .success(value):
            return .some(value)
        case .failure:
            return .none
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return .none
        case let .failure(error):
            return .some(error)
        }
    }
}

extension Result {
    public func get() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
    
    public func map<U>(_ transform: (Value) throws -> U) rethrows -> Result<U> {
        switch self {
        case let .success(value):
            return .success(try transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }
    
    public func flatMap<U>(_ transform: (Value) throws -> Result<U>) rethrows -> Result<U> {
        switch self {
        case let .success(value):
            return try transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result {
    public func recovered(_ transform: (Error) throws -> Result<Value>) rethrows -> Result<Value> {
        switch self {
        case .success:
            return self
        case let .failure(error):
            return try transform(error)
        }
    }
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .success(value):
            return "Result(\(value))"
        case let .failure(error):
            return "Result(error: \(error))"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

public func ??<Value>(lhs: Result<Value>, rhs: @autoclosure () -> Value) -> Value {
    return lhs.value ?? rhs()
}
