typealias MiddlewareProcess<Action, State> = (Action, @Sendable @escaping () async -> State, @Sendable @escaping (Action) async -> Void) async -> Void
