public enum Result<Value> {
    case Success(Value)
    case Failure(ErrorType)
}

extension Result {
    public init(@autoclosure _ f: () throws -> Value) {
        do {
            self = .Success(try f())
        } catch let error {
            self = .Failure(error)
        }
    }
    
    public var value: Value? {
        switch self {
        case let .Success(value):
            return .Some(value)
        case .Failure:
            return .None
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Success:
            return .None
        case let .Failure(error):
            return .Some(error)
        }
    }
}

extension Result {
    public func map<U>(f: Value -> U) -> Result<U> {
        switch self {
        case let .Success(value):
            return .Success(f(value))
        case let .Failure(error):
            return .Failure(error)
        }
    }
    
    public func flatMap<U>(f: Value -> Result<U>) -> Result<U> {
        switch self {
        case let .Success(value):
            return f(value)
        case let .Failure(error):
            return .Failure(error)
        }
    }
    
    public func apply<U>(f: Result<Value -> U>) -> Result<U> {
        return f.flatMap { f in self.map { f($0) } }
    }
}

public func >>-<Value, U>(lhs: Result<Value>, rhs: Value -> Result<U>) -> Result<U> {
    return lhs.flatMap(rhs)
}

public func -<<<Value, U>(lhs: Value -> Result<U>, rhs: Result<Value>) -> Result<U> {
    return rhs.flatMap(lhs)
}

public func <^><Value, U>(lhs: Value -> U, rhs: Result<Value>) -> Result<U> {
    return rhs.map(lhs)
}

public func <*><Value, U>(lhs: Result<Value -> U>, rhs: Result<Value>) -> Result<U> {
    return rhs.apply(lhs)
}

public func ??<Value>(lhs: Result<Value>, rhs: Value) -> Value {
    return lhs.value ?? rhs
}

public func pure<Value>(value: Value) -> Result<Value> {
    return .Success(value)
}
