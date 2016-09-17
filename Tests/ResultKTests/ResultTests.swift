import XCTest
@testable import ResultK

class ResultKTests: XCTestCase {
    func testInit() {
        do {
            let r: Result<Int> = Result(2)
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(try failableGetInt(2))
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(try failableGetInt(3))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "3")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testInitError() {
        let r: Result<Int> = Result(error: MyError(message: "a"))
        switch r {
        case .success:
            XCTFail()
        case let .failure(error as MyError):
            XCTAssertEqual(error.message, "a")
        case .failure:
            XCTFail()
        }
    }
    
    func testValue() {
        do {
            let r: Result<Int> = Result(2)
            if let value = r.value {
                XCTAssertEqual(value, 2)
            } else {
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError())
            if let _ = r.value {
                XCTFail()
            }
        }
    }
    
    func testError() {
        do {
            let r: Result<Int> = Result(2)
            if let _ = r.error {
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError())
            if let _ = r.error { // Cannot use `guard` because its body does not fall through
            } else {
                XCTFail()
            }
        }
    }
    
    func testMap() {
        do {
            let r: Result<Int> = Result(2).map { $0 * $0 }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError(message: "a")).map { $0 * $0 }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFlatMap() {
        do {
            let r: Result<Int> = Result(2).flatMap { Result($0 * $0) }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(2).flatMap { _ in Result(error: MyError(message: "b")) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "b")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError(message:  "a")).flatMap { Result($0 * $0) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result<Int>(error: MyError(message: "a")).flatMap { _ in Result(error: MyError(message: "b:")) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testApply() {
        do {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.apply(pure({ $0 * $0 }))
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.apply(Result(error: MyError(message: "f")))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "f")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let r: Result<Int> = a.apply(pure({ $0 * $0 }))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
        
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let r: Result<Int> = a.apply(Result(error: MyError(message: "f")))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "f")
            case .failure:
                XCTFail()
            }
        }
    }

    func testRecover() {
        do {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.recover { error in
                XCTFail()
                return Result(error: MyError())
            }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let r: Result<Int> = a.recover { error in
                switch error {
                case let error as MyError:
                    XCTAssertEqual(error.message, "a")
                default:
                    XCTFail()
                }
                return Result(2)
            }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let r: Result<Int> = a.recover { error in
                switch error {
                case let error as MyError:
                    XCTAssertEqual(error.message, "a")
                default:
                    XCTFail()
                }
                return Result(error: MyError(message: "b"))
            }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "b")
            case .failure:
                XCTFail()
            }
        }
    }

    func testFlatMapLeftOperator() {
        do {
            let r: Result<Int> = Result(2) >>- { Result($0 * $0) }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(2) >>- { _ in Result(error: MyError(message: "b")) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "b")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError(message:  "a")) >>- { Result($0 * $0) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result<Int>(error: MyError(message: "a")) >>- { _ in Result(error: MyError(message: "b:")) }
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFlatMapRightOperator() {
        do {
            let r: Result<Int> = { Result($0 * $0) } -<< Result(2)
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = { _ in Result(error: MyError(message: "b")) } -<< Result(2)
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "b")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = { Result($0 * $0) } -<< Result(error: MyError(message:  "a"))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = { _ in Result(error: MyError(message: "b:")) } -<< Result<Int>(error: MyError(message: "a"))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testMapOperator() {
        do {
            let r: Result<Int> = { $0 * $0 } <^> Result(2)
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 4)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = { $0 * $0 } <^> Result(error: MyError(message: "a"))
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testApplyOperator() {
        do {
            let a: Result<Int> = Result(2)
            let b: Result<Int> = Result(3)
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 5)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(2)
            let b: Result<Int> = Result(error: MyError(message: "b"))
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "b")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let b: Result<Int> = Result(3)
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            let b: Result<Int> = Result(error: MyError(message: "b"))
            let r: Result<Int> = pure(curry(+)) <*> a <*> b
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "a")
            case .failure:
                XCTFail()
            }
        }
    }

    func testFailureCoalescingOperator() {
        do {
            let a: Result<Int> = Result(2)
            let r: Int = a ?? 3
            XCTAssertEqual(r, 2)
        }
        
        do {
            let a: Result<Int> = Result(error: MyError())
            let r: Int = a ?? 3
            XCTAssertEqual(r, 3)
        }
    }
    
    func testPure() {
        do {
            let r: Result<Int> = pure(2)
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
    }

    func testTryr() {
        do {
            let r: Result<Int> = tryr(failableGetInt)(2)
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = tryr(failableGetInt)(3)
            switch r {
            case .success:
                XCTFail()
            case let .failure(error as MyError):
                XCTAssertEqual(error.message, "3")
            case .failure:
                XCTFail()
            }
        }
    }

    func testSample() {
        func primeOrFailure(_ x: Int) -> Result<Int> {
            guard [2, 3, 5, 7, 11].contains(x) else {
                return Result(error: MyError())
            }
            return Result(x)
        }
        func primeOrThrow(_ x: Int) throws -> Int {
            guard [2, 3, 5, 7, 11].contains(x) else {
                throw MyError()
            }
            return x
        }
        
        let a: Result<Int> = Result(try primeOrThrow(2))
        switch a {
        case let .success(value):
            print(value)
        case let .failure(error):
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
    
    static var allTests: [(String, (ResultKTests) -> () throws -> Void)] {
        return [
            ("testSample", testInit),
            ("testSample", testInitError),
            ("testSample", testValue),
            ("testSample", testError),
            ("testSample", testMap),
            ("testSample", testFlatMap),
            ("testSample", testApply),
            ("testSample", testRecover),
            ("testSample", testFlatMapLeftOperator),
            ("testSample", testFlatMapRightOperator),
            ("testSample", testMapOperator),
            ("testSample", testApplyOperator),
            ("testSample", testFailureCoalescingOperator),
            ("testSample", testPure),
            ("testSample", testTryr),
            ("testSample", testSample),
        ]
    }
}

private func failableGetInt(_ x: Int) throws -> Int {
    guard x % 2 == 0 else {
        throw MyError(message: "\(x)")
    }
    return x
}

private struct MyError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    init() {
        self.init(message: "")
    }
}

private func curry<T, U, V>(_ f: @escaping (T, U) -> V) -> (T) -> (U) -> V {
    return { t in { u in f(t, u) } }
}

