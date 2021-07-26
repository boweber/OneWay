public final class PassthroughElement<Element>: AsyncSequence {
    public typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    private var stream: AsyncStream<Element>! = nil
    private var continuation: AsyncStream<Element>.Continuation! = nil
    
    init() {
        stream = AsyncStream { (continuation: AsyncStream<Element>.Continuation) in
            self.continuation = continuation
        }
    }
    
    func yield(_ input: Element) {
        continuation.yield(input)
    }
    
    public func finish() {
        continuation.finish()
    }
    
    public func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        stream.makeAsyncIterator()
    }
}
