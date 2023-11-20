# Swift NanoID

A really simple [NanoID](https://github.com/ai/nanoid) implementation for the Swift programming language.

## Install

Add the repository as a dependency:

```swift
.package(url: "https://github.com/binarybirds/swift-nanoid", from: "1.0.0"),
```

Add `NanoID` to the target dependencies:

```swift
.product(name: "NanoID", package: "swift-nanoid"),
```

Update the packages and you are ready.

## Usage example

Basic example

```swift
import NanoID

let id = NanoID()
print(id)
```
