[![Swift Version](https://img.shields.io/badge/Swift-5.1-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![Build status](https://travis-ci.org/Nekitosss/CombineReplaceWithPublisher.svg?branch=master)](http://travis-ci.org)


# CombineReplaceWithPublisher

Implementation of two Publishers. First one for catching empty result and transforming it into new sequence, second for catching error result.

## Usage

```swift
// If possibleEmptyPublisher will complete without emitting value, handlingPublisher will be used.

let handlingPublisher = Result.Publisher<Int, Error>(.success(5)) // For example

possibleEmptyPublisher
    .replaceEmpty(handlingPublisher)
    .sink(...)
    .store(in: &cancellable)

```

```swift
// If possibleErrorPublisher will complete with error, handlingPublisher will be used.

let handlingPublisher = Result.Publisher<Int, Error>(.success(5)) // For example

possibleErrorPublisher
    .replaceError(handlingPublisher)
    .sink(...)
    .store(in: &cancellable)
```

You alse could chain error and ampty handling:

```swift
// secondAttemptToRecover will be used if both possibleErrorPublisher and handlingPublisher will emit error

possibleErrorPublisher
    .replaceError(handlingPublisher)
    .replaceError(secondAttemptToRecoverPublisher)
```

### Installation

#### Via SwiftPM

`https://github.com/Nekitosss/CombineReplaceWithPublisher.git`

## Requirements

Swift 5.1, iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+