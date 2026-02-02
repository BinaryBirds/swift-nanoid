# Swift NanoID

A really simple [NanoID](https://github.com/ai/nanoid) implementation for the Swift programming language.

[![Release: 1.1.1](https://img.shields.io/badge/Release-1.1.1-F05138)]( https://github.com/binarybirds/swift-nanoid/releases/tag/1.1.1)

## Features

- Effortless NanoID generation
- Non-cryptographically secure randomness
- Designed for modern Swift concurrency
- DocC-based API Documentation
- Unit tests and code coverage

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)

- Swift 6.1+
- Platforms:
  - macOS 15+
  - iOS 18+
  - tvOS 18+
  - watchOS 11+
  - visionOS 2+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/binarybirds/swift-nanoid", from: "1.1.1"),
```

Then add `SwiftNanoID` to your target dependencies:

```swift
.product(name: "NanoID", package: "swift-nanoid"),
```

Update the packages and you are ready.

## Usage

[![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)](https://binarybirds.github.io/swift-nanoid)

API documentation is available at the following link.

## Basic example

```swift
import NanoID

let id = NanoID()
print(id)
```

## Development

- Build: `swift build`
- Test:
  - local: `swift test`
  - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/BinaryBirds/swift-nanoid/pulls) are welcome. Please keep changes focused and include tests for new logic.
