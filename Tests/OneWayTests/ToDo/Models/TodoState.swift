import OneWay

enum TodoState: Sendable, Initialisable, Equatable {
    case initial
    case loading
    case received([ToDo])
    case failed(Error)
    
    static func == (lhs: TodoState, rhs: TodoState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loading, .loading): return true
        case let (.received(lhsElements), .received(rhsElements)): return lhsElements == rhsElements
        case (.failed, .failed): return true
        default: return false
        }
    }
}
