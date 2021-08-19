public struct Pipeline<Middleware: MiddlewareProtocol> {
    public typealias Action = Middleware.Action
    public typealias State = Middleware.State
    
    let middleware: Middleware?
    let reducer: Reducer<Action, State>
    
    public func lifted<GlobalAction: Sendable, GlobalState: Sendable>(
        input: KeyPath<GlobalAction, Middleware.Action?>,
        output: @escaping (Middleware.Action) -> GlobalAction,
        state: WritableKeyPath<GlobalState, Middleware.State>
    ) -> Pipeline<LiftedMiddleware<GlobalAction, GlobalState, Middleware>> {
        Pipeline<LiftedMiddleware<GlobalAction, GlobalState, Middleware>>(
            middleware: middleware.map { LiftedMiddleware<GlobalAction, GlobalState, Middleware>(
                base: $0,
                input: { $0[keyPath: input] },
                output: output,
                state: { $0[keyPath: state] }
            )
            }
        ) { globalAction, globalMutableState in
            guard let action = globalAction[keyPath: input] else { return }
            reducer(action, &globalMutableState[keyPath: state])
        }
    }
}

extension Pipeline {
    public init(@PipelineBuilder<Middleware> _ builder: () -> Pipeline<Middleware>) {
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
            middleware: LiftedMiddleware<Action, State, M>(
                base: middleware,
                input: { $0 },
                output: { $0 },
                state: { _ in fatalError() }
            ),
            reducer: reduce
        )
    }
}
