public final class CurrentElement<Element>: AsyncSequence {
    public typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    public private(set) var currentElement: Element
    private var stream: AsyncStream<Element>! = nil
    private var continuation: AsyncStream<Element>.Continuation! = nil
    
    init(initialElement: Element) {
        currentElement = initialElement
        stream = AsyncStream { (continuation: AsyncStream<Element>.Continuation) in
            self.continuation = continuation
        }
    }
    
    func update(_ transform: (inout Element) -> Void) {
        transform(&currentElement)
        continuation.yield(currentElement)
    }
    
    public func finish() {
        continuation.finish()
    }
    
    public func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        stream.makeAsyncIterator()
    }
}
