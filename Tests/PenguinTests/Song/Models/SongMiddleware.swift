import Penguin

struct SongMiddleware: MiddlewareProtocol {
    let dismissedAction: (SongAction) -> Void
    let state: (SongState) -> Void
    let error: Error?

    func process(_ action: SongAction, in currentState: @Sendable @escaping () async -> SongState, dispatch: @Sendable @escaping (SongAction) async -> Void) async {
        guard case .requestFavouriteSong = action else {
            dismissedAction(action)
            return
        }
        state(await currentState())
        await Task.sleep(3) // 3 nanoseconds
        if let error = error {
            await dispatch(.fail(error))
        } else {
            await dispatch(.load(.blueworld))
        }
    }
}
