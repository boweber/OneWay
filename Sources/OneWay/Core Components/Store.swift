public actor Store<Middleware: MiddlewareProtocol> {
    public typealias State = Middleware.State
    public typealias Action = Middleware.Action
    public typealias DispatchID = Int
    
    private var state: State
    private var cancellableTasks: [DispatchID: Task<Void, Never>]
    let reducer: Reducer<Action, State>
    let middleware: Middleware?
    @MainActor public let currentState: PassthroughElement<State>
    
    init(state: State, middleware: Middleware?, reducer: @escaping Reducer<Action, State>) {
        self.reducer = reducer
        self.state = state
        self.middleware = middleware
        self.cancellableTasks = [:]
        self.currentState = PassthroughElement<State>()
    }
    
    public convenience init(initialState: State, middleware: Middleware, reducer: @escaping Reducer<Action, State>) {
        self.init(state: initialState, middleware: middleware, reducer: reducer)
    }
    
    public convenience init<M: MiddlewareProtocol, A, S>(
        initialState: State,
        middleware: M,
        reducer: @escaping Reducer<A, S>
    ) where Middleware == BaseMiddleware<A, S>, M.State == Never, M.Action == A {
        self.init(state: initialState, middleware: middleware.liftUnusedState(to: S.self), reducer: reducer)
    }
    
    public convenience init<A, S>(initialState: S, reducer: @escaping Reducer<A, S>) where Middleware == PlaceholderMiddleware<A, S> {
        self.init(state: initialState, middleware: nil, reducer: reducer)
    }

    @Sendable
    private func updateState(with action: Action) async {
        reducer(action, &state)
        currentState.yield(state)
    }

    @discardableResult
    public func dispatch(@Tracing _ action: Action, priority: TaskPriority? = nil) -> DispatchID {
        let id = IDFactory.nextID
        cancellableTasks[id] = Task(priority: priority) {
            defer { cancellableTasks[id] = nil }
            await updateState(with: action)
            await middleware?.process(action, in: { @Sendable in await self.state }, dispatch: updateState)
        }
        return id
    }
    
    public func cancel(_ dispatchID: DispatchID) {
        cancellableTasks[dispatchID]?.cancel()
        cancellableTasks[dispatchID] = nil
    }
    
    public func cancelAllRunningTasks() {
        for key in cancellableTasks.keys {
            cancel(key)
        }
    }
}

extension Store where State: Initialisable {
    public convenience init<A, S>(reducer: @escaping Reducer<A, S>) where Middleware == PlaceholderMiddleware<A, S> {
        self.init(state: State.initial, middleware: nil, reducer: reducer)
    }
    
    public convenience init(middleware: Middleware, reducer: @escaping Reducer<Action, State>) {
        self.init(state: State.initial, middleware: middleware, reducer: reducer)
    }
    
    public convenience init<M: MiddlewareProtocol, A, S>(
        middleware: M,
        reducer: @escaping Reducer<A, S>
    ) where Middleware == BaseMiddleware<A, S>, M.State == Never, M.Action == A {
        self.init(initialState: State.initial, middleware: middleware, reducer: reducer)
    }
    
    public nonisolated static func +<M: MiddlewareProtocol>(
        _ lhs: Store<Middleware>,
        _ rhs: Store<M>
    ) -> Store<BaseMiddleware<Action, State>> where Action == M.Action, State == M.State {
        Store<BaseMiddleware<Action, State>>(
            state: State.initial,
            middleware: lhs.middleware + rhs.middleware
        ) { action, mutableState in
            lhs.reducer(action, &mutableState)
            rhs.reducer(action, &mutableState)
        }
    }
}

extension Store {
    public nonisolated func lift<GlobalAction: Sendable, GlobalState>(
        input: KeyPath<GlobalAction, Middleware.Action?>,
        state: WritableKeyPath<GlobalState, Middleware.State>,
        output: @escaping (Middleware.Action) -> GlobalAction
    ) -> Store<BaseMiddleware<GlobalAction, GlobalState>> where GlobalState: Initialisable {
        Store<BaseMiddleware<GlobalAction, GlobalState>>(
            state: GlobalState.initial,
            middleware: middleware?.lift(
                mapGlobalAction: { $0[keyPath: input] },
                mapAction: output,
                mapGlobalState: { $0[keyPath: state] }
            )) { globalAction, mutableState in
            guard let action = globalAction[keyPath: input] else { return }
            self.reducer(action, &mutableState[keyPath: state])
        }
    }
}

private extension Optional {
    static func +<Middleware: MiddlewareProtocol>(
        _ lhs: Self,
        _ rhs: Middleware?
    ) -> BaseMiddleware<Wrapped.Action, Wrapped.State>?
    where Wrapped: MiddlewareProtocol, Middleware.Action == Wrapped.Action, Middleware.State == Wrapped.State {
        switch (lhs, rhs) {
        case let (.some(lhs), .some(rhs)): return lhs + rhs
        case (.some(let lhs), .none): return lhs.eraseToBaseMiddleware()
        case (.none, .some(let rhs)): return rhs.eraseToBaseMiddleware()
        default: return nil
        }
    }
}
