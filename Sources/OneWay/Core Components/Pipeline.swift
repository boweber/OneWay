/// A pipeline acts as a container for an optional middleware and an associated reducer.
public struct Pipeline<Middleware: MiddlewareProtocol> {
    public typealias Action = Middleware.Action
    public typealias State = Middleware.State
    
    let middleware: Middleware?
    let reducer: Reducer<Action, State>
    
    private func lifted<GlobalAction: Sendable, GlobalState: Sendable>(
        input: @escaping (GlobalAction) -> Action?,
        output: @escaping (Middleware.Action) -> GlobalAction,
        state: WritableKeyPath<GlobalState, Middleware.State>
    ) -> Pipeline<LiftedMiddleware<GlobalAction, GlobalState, Middleware>> {
        Pipeline<LiftedMiddleware<GlobalAction, GlobalState, Middleware>>(
            middleware: middleware.map { LiftedMiddleware<GlobalAction, GlobalState, Middleware>(
                base: $0,
                input: input,
                output: output,
                state: { globalState in globalState[keyPath: state] }
            )
            }
        ) { globalAction, globalMutableState in
            guard let action = input(globalAction) else { return }
            reducer(action, &globalMutableState[keyPath: state])
        }
    }
    
    public func lifted<GlobalAction: Sendable, GlobalState: Sendable>(
        input: KeyPath<GlobalAction, Middleware.Action?>,
        output: @escaping (Middleware.Action) -> GlobalAction,
        state: WritableKeyPath<GlobalState, Middleware.State>
    ) -> Pipeline<LiftedMiddleware<GlobalAction, GlobalState, Middleware>> {
        lifted(input: { $0[keyPath: input] }, output: output, state: state)
    }
    
    public func lifted<GlobalAction: Sendable>(
        input: KeyPath<GlobalAction, Middleware.Action?>,
        output: @escaping (Middleware.Action) -> GlobalAction
    ) -> Pipeline<LiftedMiddleware<GlobalAction, State, Middleware>> {
        lifted(input: input, output: output, state: \.self)
    }
    
    public func lifted<GlobalState: Sendable>(
        state: WritableKeyPath<GlobalState, Middleware.State>
    ) -> Pipeline<LiftedMiddleware<Action, GlobalState, Middleware>> {
        lifted(input: { $0 }, output: { $0 }, state: state)
    }
}

extension Pipeline {
    public init(@PipelineBuilder _ builder: () -> Pipeline<Middleware>) {
        self = builder()
    }
    
    public init(middleware: Middleware, _ reduce: @escaping Reducer<Action, State>) {
        self.init(middleware: middleware, reducer: reduce)
    }
    
    public init<A, S>(_ reduce: @escaping Reducer<A, S>) where Middleware == PlaceholderMiddleware<A, S> {
        self.init(middleware: nil, reducer: reduce)
    }
    
    public init<M: MiddlewareProtocol, A, S>(
        middleware: M, _ reduce: @escaping Reducer<A, S>
    ) where M.State == Never, M.Action == A, Middleware == LiftedMiddleware<A, S, M> {
        self.init(
            middleware: middleware.liftState(to: S.self),
            reducer: reduce
        )
    }
}
