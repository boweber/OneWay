enum IDFactory {
    private static var ids = sequence(first: 1, next: {$0 + 1})
    static var nextID: Int {
        ids.next()!
    }
}
