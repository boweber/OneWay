public enum PlaceholderMiddleware<Action: Sendable, State: Sendable>: MiddlewareProtocol {
    public func process(_ action: Action, in currentState: @Sendable @escaping () async -> State, dispatch: @Sendable @escaping (Action) async -> Void) async {}
}
