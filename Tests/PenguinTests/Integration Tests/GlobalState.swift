import Penguin

struct GlobalState: Equatable, Sendable {
    var todo: TodoState
    var song: SongState
}

extension GlobalState: Initialisable {
    static var initial: GlobalState {
        GlobalState(todo: .initial, song: .initial)
    }
}
