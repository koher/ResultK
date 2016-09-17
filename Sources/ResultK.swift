public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

extension Result {
    public init(_ f: @autoclosure () throws -> Value) {
        do {
            self = .success(try f())
        } catch let error {
            self = .failure(error)
        }
    }
    
    public init(error: Error) {
        self = .failure(error)
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
    public func unwrapped() throws -> Value {
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
    public func recover(_ f: (Error) -> Result<Value>) -> Result<Value> {
        switch self {
        case .success:
            return self
        case let .failure(error):
            return f(error)
        }
    }
}

public func >>-<Value, U>(lhs: Result<Value>, rhs: (Value) -> Result<U>) -> Result<U> {
    return lhs.flatMap(rhs)
}

public func -<<<Value, U>(lhs: (Value) -> Result<U>, rhs: Result<Value>) -> Result<U> {
    return rhs.flatMap(lhs)
}

public func <^><Value, U>(lhs: (Value) -> U, rhs: Result<Value>) -> Result<U> {
    return rhs.map(lhs)
}

public func <*><Value, U>(lhs: Result<(Value) -> U>, rhs: Result<Value>) -> Result<U> {
    return rhs.apply(lhs)
}

public func ??<Value>(lhs: Result<Value>, rhs: @autoclosure () -> Value) -> Value {
    return lhs.value ?? rhs()
}
