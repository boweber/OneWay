import OneWay

struct GlobalState: Equatable, Sendable {
    var todo: TodoState
    var song: SongState
}

extension GlobalState {
    static var initial: GlobalState {
        GlobalState(todo: .initial, song: .initial)
    }
}
