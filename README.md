# OneWay

OneWay is a swift package providing libraries to implement and test a unidirectional architecture pattern without any external dependencies (e.g., Combine, etc.). It only makes use of the newly introduced concurrency features of swift.

**Note**: This package is currently a work in progress and might not perform as expected. 

## Contributions
Contributions are very welcome!

## Inspired by

- [SwiftRex](https://github.com/SwiftRex/SwiftRex)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture#what-is-the-composable-architecture)

## Notes

- Due to efficiency problems the type erasing middleware was removed. See [swift forums](https://forums.swift.org/t/anyasyncsequence/50828/2) for more details.
