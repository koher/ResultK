ResultK
============================

_ResultK_ provides `Result` suitable to Swift's untyped `throws`. The `Result` does not have the second type parameter to specify the error type unlike [antitypical/Result](https://github.com/antitypical/Result).

```swift
let a: Result<Int> = Result(try primeOrThrow(2))
switch a {
case let .Success(value):
    print(value)
case let .Failure(error):
    print(error)
}
```

`tryr` is also available to wrap values returned by throwable functions. It is similar to `try?` for `Optional`.

```swift
// let b: Result<Int> = tryr primeOrThrow(3)
let b: Result<Int> = tryr(primeOrThrow)(3)
```

`Result` behaves as a _monad_. Operators are compatible to ones defined in [thoughtbot/Runes](https://github.com/thoughtbot/runes).

```swift
let sum1: Result<Int> = a.flatMap { a in b.map { b in a + b } }
let sum2: Result<Int> = a >>- { a in  b >>- { b in  pure(a + b) } }
let sum3: Result<Int> = curry(+) <^> a <*> b
// all expressions return Result(5)
```

Installation
----------------------------

### Carthage

[_Carthage_](https://github.com/Carthage/Carthage) is available to install _ResultK_. Add it to your _Cartfile_:

```
github "koher/ResultK" "master"
```

### Manually

1. Put [ResultK.xcodeproj](ResultK.xcodeproj) into your project in Xcode.
2. Click the project icon and select the "General" tab.
3. Add ResultK.framework to "Embedded Binaries".
4. `import ResultK` in your swift files.

License
----------------------------

[The MIT License](LICENSE)
