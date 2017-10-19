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
}

extension Result {
    public func map<U>(_ f: (Value) -> U) -> Result<U> {
        switch self {
        case let .success(value):
            return .success(f(value))
        case let .failure(error):
            return .failure(error)
        }
    }
    
    public func flatMap<U>(_ f: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(value):
            return f(value)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    public func apply<U>(_ f: Result<(Value) -> U>) -> Result<U> {
        return f.flatMap { f in self.map { f($0) } }
    }
}

extension Result {
    public func recovered(_ f: (Error) -> Result<Value>) -> Result<Value> {
        switch self {
        case .success:
            return self
        case let .failure(error):
            return f(error)
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
