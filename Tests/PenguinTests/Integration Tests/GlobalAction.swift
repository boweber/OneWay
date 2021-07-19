enum GlobalAction: Sendable {
    case songAction(SongAction)
    case todoAction(TodoAction)
    
    
}
extension GlobalAction {
    public var songAction: SongAction? {
        get {
            guard case let .songAction(value) = self else { return nil }
            return value
        }
        set {
            guard case .songAction = self, let newValue = newValue else { return }
            self = .songAction(newValue)
        }
    }
    
    public var todoAction: TodoAction? {
        get {
            guard case let .todoAction(value) = self else { return nil }
            return value
        }
        set {
            guard case .todoAction = self, let newValue = newValue else { return }
            self = .todoAction(newValue)
        }
    }
}
