import XCTest
@testable import ResultK

class ResultTests: XCTestCase {
    func testInit() {
        if true {
            let r: Result<Int> = Result(2)
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(try failableGetInt(2))
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }

        if true {
            let r: Result<Int> = Result(try failableGetInt(3))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "3")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testInitError() {
        let r: Result<Int> = Result(error: Error(message: "a"))
        switch r {
        case .Success:
            XCTFail()
        case let .Failure(error as Error):
            XCTAssertEqual(error.message, "a")
        case .Failure:
            XCTFail()
        }
    }
    
    func testValue() {
        if true {
            let r: Result<Int> = Result(2)
            if let value = r.value {
                XCTAssertEqual(value, 2)
            } else {
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(error: Error())
            if let _ = r.value {
                XCTFail()
            }
        }
    }
    
    func testError() {
        if true {
            let r: Result<Int> = Result(2)
            if let _ = r.error {
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(error: Error())
            if let _ = r.error { // Cannot use `guard` because its body does not fall through
            } else {
                XCTFail()
            }
        }
    }
}

extension ResultTests {
    func testMap() {
        if true {
            let r: Result<Int> = Result(2).map { $0 * $0 }
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(error: Error(message: "a")).map { $0 * $0 }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testFlatMap() {
        if true {
            let r: Result<Int> = Result(2).flatMap { Result($0 * $0) }
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(2).flatMap { _ in Result(error: Error(message: "b")) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "b")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(error: Error(message:  "a")).flatMap { Result($0 * $0) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result<Int>(error: Error(message: "a")).flatMap { _ in Result(error: Error(message: "b:")) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testApply() {
        if true {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.apply(pure({ $0 * $0 }))
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.apply(Result(error: Error(message: "f")))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "f")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let r: Result<Int> = a.apply(pure({ $0 * $0 }))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }

        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let r: Result<Int> = a.apply(Result(error: Error(message: "f")))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "f")
            case .Failure:
                XCTFail()
            }
        }
    }
}

extension ResultTests {
    func testRecover() {
        if true {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.recover { error in
                XCTFail()
                return Result(error: Error())
            }
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let r: Result<Int> = a.recover { error in
                switch error {
                case let error as Error:
                    XCTAssertEqual(error.message, "a")
                default:
                    XCTFail()
                }
                return Result(2)
            }
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let r: Result<Int> = a.recover { error in
                switch error {
                case let error as Error:
                    XCTAssertEqual(error.message, "a")
                default:
                    XCTFail()
                }
                return Result(error: Error(message: "b"))
            }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "b")
            case .Failure:
                XCTFail()
            }
        }
    }
}

extension ResultTests {
    func testFlatMapOperator() {
        if true {
            let r: Result<Int> = Result(2) >>- { Result($0 * $0) }
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(2) >>- { _ in Result(error: Error(message: "b")) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "b")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result(error: Error(message:  "a")) >>- { Result($0 * $0) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = Result<Int>(error: Error(message: "a")) >>- { _ in Result(error: Error(message: "b:")) }
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testFlippedFlatMapOperator() {
        if true {
            let r: Result<Int> = { Result($0 * $0) } -<< Result(2)
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = { _ in Result(error: Error(message: "b")) } -<< Result(2)
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "b")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = { Result($0 * $0) } -<< Result(error: Error(message:  "a"))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = { _ in Result(error: Error(message: "b:")) } -<< Result<Int>(error: Error(message: "a"))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testMapOperator() {
        if true {
            let r: Result<Int> = { $0 * $0 } <^> Result(2)
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 4)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = { $0 * $0 } <^> Result(error: Error(message: "a"))
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
    
    func testApplyOperator() {
        if true {
            let a: Result<Int> = Result(2)
            let b: Result<Int> = Result(3)
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 5)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(2)
            let b: Result<Int> = Result(error: Error(message: "b"))
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "b")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let b: Result<Int> = Result(3)
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let a: Result<Int> = Result(error: Error(message: "a"))
            let b: Result<Int> = Result(error: Error(message: "b"))
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "a")
            case .Failure:
                XCTFail()
            }
        }
    }
}

extension ResultTests {
    func testFailureCoalescingOperator() {
        if true {
            let a: Result<Int> = Result(2)
            let r: Int = a ?? 3
            XCTAssertEqual(r, 2)
        }
        
        if true {
            let a: Result<Int> = Result(error: Error())
            let r: Int = a ?? 3
            XCTAssertEqual(r, 3)
        }
    }
    
}

extension ResultTests {
    func testPure() {
        if true {
            let r: Result<Int> = pure(2)
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }
    }
}

extension ResultTests {
    func testTryr() {
        if true {
            let r: Result<Int> = tryr(failableGetInt)(2)
            switch r {
            case let .Success(value):
                XCTAssertEqual(value, 2)
            case .Failure:
                XCTFail()
            }
        }
        
        if true {
            let r: Result<Int> = tryr(failableGetInt)(3)
            switch r {
            case .Success:
                XCTFail()
            case let .Failure(error as Error):
                XCTAssertEqual(error.message, "3")
            case .Failure:
                XCTFail()
            }
        }
    }
}

private func failableGetInt(x: Int) throws -> Int {
    guard x % 2 == 0 else {
        throw Error(message: "\(x)")
    }
    return x
}

private struct Error: ErrorType {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    init() {
        self.init(message: "")
    }
}

private func curry<T, U, V>(f: (T, U) -> V) -> T -> U -> V {
    return { t in { u in f(t, u) } }
}

extension ResultTests {
    func testSample() {
        func primeOrFailure(x: Int) -> Result<Int> {
            guard [2, 3, 5, 7, 11].contains(x) else {
                return Result(error: Error())
            }
            return Result(x)
        }
        func primeOrThrow(x: Int) throws -> Int {
            guard [2, 3, 5, 7, 11].contains(x) else {
                throw Error()
            }
            return x
        }
        
        let a: Result<Int> = Result(try primeOrThrow(2))
        switch a {
        case let .Success(value):
            print(value)
        case let .Failure(error):
            print(error)
        }
        
        // let b: Result<Int> = tryr primeOrThrow(3)
        let b: Result<Int> = tryr(primeOrThrow)(3)

        let sum1: Result<Int> = a.flatMap { a in b.map { b in a + b } }
        let sum2: Result<Int> = a >>- { a in  b >>- { b in  pure(a + b) } }
        let sum3: Result<Int> = curry(+) <^> a <*> b
        
        print(sum1)
        print(sum2)
        print(sum3)
    }
}