public struct LiftedMiddleware<GlobalAction: Sendable, GlobalState: Sendable, Middleware: MiddlewareProtocol>: MiddlewareProtocol {
    let base: Middleware
    let input: (GlobalAction) -> Middleware.Action?
    let output: (Middleware.Action) -> GlobalAction
    let state: (GlobalState) -> Middleware.State
    
    public func process(
        _ action: GlobalAction,
        in currentState: @Sendable @escaping () async -> GlobalState,
        dispatch: @Sendable @escaping (GlobalAction) async -> Void
    ) async {
        guard let localAction = input(action) else { return }
        await base.process(
            localAction,
            in: { await state(currentState()) },
            dispatch: { await dispatch(output($0)) }
        )
    }
}
