public actor Store<Middleware: MiddlewareProtocol> {
    public typealias State = Middleware.State
    public typealias Action = Middleware.Action
    public typealias DispatchID = Int

    private var cancellableTasks: [DispatchID: Task<Void, Never>]
    private var idFactory: UnfoldSequence<DispatchID, (DispatchID?, Bool)>
    private let pipeline: Pipeline<Middleware>
    @MainActor public let currentState: CurrentElement<State>
    
    public init(initialState: State, pipeline: Pipeline<Middleware>) {
        self.pipeline = pipeline
        self.cancellableTasks = [:]
        self.currentState = CurrentElement<State>(initialElement: initialState)
        self.idFactory = sequence(first: 1, next: {$0 + 1})
    }
    
    public convenience init(initialState: State, @PipelineBuilder _ builder: () -> Pipeline<Middleware>) {
        self.init(initialState: initialState, pipeline: builder())
    }

    @Sendable
    private func updateState(with action: Action) async {
        currentState.update { [weak self] currentState in
            guard let self = self else { return }
            self.pipeline.reducer(action, &currentState)
        }
    }

    @discardableResult
    public func dispatch(_ action: Action, priority: TaskPriority? = nil) -> DispatchID {
        let id = idFactory.next()!
        cancellableTasks[id] = Task(priority: priority) {
            defer { cancellableTasks[id] = nil }
            await updateState(with: action)
            await pipeline.middleware?.process(action, in: { @Sendable in self.currentState.currentElement }, dispatch: updateState)
        }
        return id
    }
    
    public func cancel(_ dispatchIDs: DispatchID...) {
        dispatchIDs.forEach {
            cancellableTasks[$0]?.cancel()
            cancellableTasks[$0] = nil
        }
    }
    
    public func cancelAllRunningTasks() {
        for key in cancellableTasks.keys {
            cancel(key)
        }
    }
}
