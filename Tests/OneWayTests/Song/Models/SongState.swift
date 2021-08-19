enum SongState: Equatable, Sendable {
    case initial
    case loading
    case loaded(Song)
    case failed(Error)
    
    static func == (lhs: SongState, rhs: SongState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loading, .loading): return true
        case let (.loaded(lhssong), .loaded(rhssong)): return lhssong == rhssong
        case (.failed, .failed): return true
        default: return false
        }
    }
}
