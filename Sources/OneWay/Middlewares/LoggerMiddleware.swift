public struct LoggerMiddleware<Middleware: MiddlewareProtocol>: MiddlewareProtocol {
    let logging: (Context) -> Void
    let middleware: Middleware
    
    public func process(
        _ action: Middleware.Action,
        in currentState: @Sendable @escaping () async -> Middleware.State,
        dispatch: @Sendable @escaping (Middleware.Action) async -> Void
    ) async {
        logging(.startsProcessing(action))
        defer {
            logging(.stopsProcessing(action))
        }
        
        let _dispatch: @Sendable (Action) async -> Void = { dispatchingAction in
            logging(.dispatching(action))
            await dispatch(dispatchingAction)
        }
        
        let _currentState: @Sendable () async -> State = {
            let currentState = await currentState()
            logging(.receiving(currentState))
            return currentState
        }
        await middleware.process(action, in: _currentState, dispatch: _dispatch)
    }
    
    public enum Context: Sendable {
        case startsProcessing(Middleware.Action)
        case stopsProcessing(Middleware.Action)
        case dispatching(Middleware.Action)
        case receiving(Middleware.State)
    }
}

extension MiddlewareProtocol {
    public func logEvents(
        _ log: @Sendable @escaping (LoggerMiddleware<Self>.Context) -> Void
    ) -> LoggerMiddleware<Self> {
        LoggerMiddleware(logging: log, middleware: self)
    }
}
