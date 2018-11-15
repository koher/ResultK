# ResultK

_ResultK_ provides `Result` suitable to Swift's untyped `throws`. _ResultK_'s `Result` type does not have the second type parameter to specify the error type unlike [antitypical/Result](https://github.com/antitypical/Result).

```swift
let a: Result<Int> = Result { try primeOrThrow(2) }
switch a {
case let .success(value):
    print(value)
case let .failure(error):
    print(error)
}
```

`Result` is a _monad_.  `map` and `flatMap` are available for `Result`.

```swift
let b: Result<Int> = Result(3)
let sum: Result<Int> = a.flatMap { a in b.map { b in a + b } } // Result(5)
```

## Installation

### Swift Package Manager

Add the following to `dependencies` in your _Package.swift_.

```swift
.package(
    url: "https://github.com/koher/ResultK.git",
    from: "0.2.0-alpha"
)
```

### Carthage

```
github "koher/ResultK" "master"
```

# License

[The MIT License](LICENSE)
