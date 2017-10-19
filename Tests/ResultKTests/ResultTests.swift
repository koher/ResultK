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
            let r: Result<Int> = Result { try failableGetInt(2) }
            switch r {
            case let .success(value):
                XCTAssertEqual(value, 2)
            case .failure:
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result { try failableGetInt(3) }
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
    
    func testGet() {
        do {
            let r: Result<Int> = Result(2)
            do {
                let value = try r.get()
                XCTAssertEqual(value, 2)
            } catch {
                XCTFail()
            }
        }
        
        do {
            let r: Result<Int> = Result(error: MyError(message: "a"))
            do {
                _ = try r.get()
                XCTFail()
            } catch let error as MyError {
                XCTAssertEqual(error.message, "a")
            } catch  {
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
            let r: Result<Int> = a.apply(Result({ $0 * $0 }))
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
            let r: Result<Int> = a.apply(Result({ $0 * $0 }))
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

    func testRecovered() {
        do {
            let a: Result<Int> = Result(2)
            let r: Result<Int> = a.recovered { error in
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
            let r: Result<Int> = a.recovered { error in
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
            let r: Result<Int> = a.recovered { error in
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
    
    func testDescription() {
        do {
            let a: Result<Int> = Result(2)
            XCTAssertEqual(a.description, "Result(2)")
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            XCTAssertEqual(a.description, "Result(error: MyError(message: a))")
        }
    }

    func testDebugDescription() {
        do {
            let a: Result<Int> = Result(2)
            XCTAssertEqual(a.debugDescription, "Result(2)")
        }
        
        do {
            let a: Result<Int> = Result(error: MyError(message: "a"))
            XCTAssertEqual(a.debugDescription, "Result(error: MyError(message: a))")
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
        
        let a: Result<Int> = Result { try primeOrThrow(2) }
        switch a {
        case let .success(value):
            print(value)
        case let .failure(error):
            print(error)
        }
        
        let b: Result<Int> = Result(3)
        
        let sum: Result<Int> = a.flatMap { a in b.map { b in a + b } }
        
        print(sum)
        
        XCTAssertEqual(sum.value!, 5)
    }
    
    static var allTests: [(String, (ResultKTests) -> () throws -> Void)] {
        return [
            ("testInit", testInit),
            ("testInitError", testInitError),
            ("testValue", testValue),
            ("testError", testError),
            ("testGet", testGet),
            ("testMap", testMap),
            ("testFlatMap", testFlatMap),
            ("testApply", testApply),
            ("testRecovered", testRecovered),
            ("testDescription", testDescription),
            ("testDebugDescription", testDebugDescription),
            ("testFailureCoalescingOperator", testFailureCoalescingOperator),
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

private struct MyError: Error, CustomStringConvertible {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    init() {
        self.init(message: "")
    }
    
    var description: String {
        return "MyError(message: \(message))"
    }
}

private func curry<T, U, V>(_ f: @escaping (T, U) -> V) -> (T) -> (U) -> V {
    return { t in { u in f(t, u) } }
}

