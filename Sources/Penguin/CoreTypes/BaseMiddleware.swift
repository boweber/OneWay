public struct BaseMiddleware<Action: Sendable, State: Sendable>: MiddlewareProtocol {
    let tasks: [MiddlewareProcess<Action, State>]
    
    public func process(_ action: Action, in currentState: @Sendable @escaping () async -> State, dispatch: @Sendable @escaping (Action) async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.async {
                    await task(action, currentState, dispatch)
                }
            }
        }
    }
}

extension MiddlewareProtocol {
    func eraseToBaseMiddleware() -> BaseMiddleware<Action, State> {
        self as? BaseMiddleware ?? BaseMiddleware(tasks: [process])
    }

    static func +<Middleware: MiddlewareProtocol>(_ lhs: Self, _ rhs: Middleware) -> BaseMiddleware<Action, State>
    where Middleware.Action == Action, Middleware.State == State {
        BaseMiddleware(tasks: lhs.eraseToBaseMiddleware().tasks + rhs.eraseToBaseMiddleware().tasks)
    }

    func lift<GlobalAction: Sendable, GlobalState: Sendable>(
        mapInputAction: @escaping (GlobalAction) -> Action?,
        mapOutputAction: @escaping (Action) -> GlobalAction,
        mapState: @escaping (GlobalState) -> State
    ) -> BaseMiddleware<GlobalAction, GlobalState> {
        BaseMiddleware<GlobalAction, GlobalState>(
            tasks: eraseToBaseMiddleware()
                .tasks
                .map { (task: @escaping MiddlewareProcess<Action, State>) -> MiddlewareProcess<GlobalAction, GlobalState> in
            { globalAction, globalState, dispatchGlobalAction in
                guard let action = mapInputAction(globalAction) else { return }
                let dispatchLocalAction: @Sendable (Action) async -> Void = { dispatchAction in
                    await dispatchGlobalAction(mapOutputAction(dispatchAction))
                }
                await task(action, { await mapState(globalState()) }, dispatchLocalAction)
            }
        }
        )
    }
}
