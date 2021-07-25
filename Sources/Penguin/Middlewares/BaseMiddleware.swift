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
        mapGlobalAction: @escaping (GlobalAction) -> Action?,
        mapAction: @escaping (Action) -> GlobalAction,
        mapGlobalState: @escaping (GlobalState) -> State
    ) -> BaseMiddleware<GlobalAction, GlobalState> {
        BaseMiddleware<GlobalAction, GlobalState>(
            tasks: eraseToBaseMiddleware()
                .tasks
                .map { (task: @escaping MiddlewareProcess<Action, State>) -> MiddlewareProcess<GlobalAction, GlobalState> in
                    { globalAction, globalState, dispatchGlobalAction in
                        guard let action = mapGlobalAction(globalAction) else { return }
                        let dispatchLocalAction: @Sendable (Action) async -> Void = { dispatchAction in
                            await dispatchGlobalAction(mapAction(dispatchAction))
                        }
                        await task(action, { await mapGlobalState(globalState()) }, dispatchLocalAction)
                    }
                }
        )
    }
    
    func lift<GlobalAction: Sendable, GlobalState: Sendable>(
        mapGlobalAction: @escaping (GlobalAction) -> Action?,
        mapAction: @escaping (Action) -> GlobalAction
    ) -> BaseMiddleware<GlobalAction, GlobalState> where State == Never {
        self.lift(mapGlobalAction: mapGlobalAction, mapAction: mapAction) { _ in
            fatalError()
        }
    }
    
    func liftUnusedState<GlobalState: Sendable>(
        to globalState: GlobalState.Type = GlobalState.self
    ) -> BaseMiddleware<Action, GlobalState> where State == Never {
        lift(mapGlobalAction: { $0 }, mapAction: { $0 })
    }
}
