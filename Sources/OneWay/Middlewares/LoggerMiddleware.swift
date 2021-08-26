public struct LoggerMiddleware<Middleware: MiddlewareProtocol, Logger>: MiddlewareProtocol {
    let logger: Logger
    let logging: (Logger, Context) -> Void
    let middleware: Middleware
    
    public func process(
        _ action: Middleware.Action,
        in currentState: @Sendable @escaping () async -> Middleware.State,
        dispatch: @Sendable @escaping (Middleware.Action) async -> Void
    ) async {
        logging(logger, .startsProcessing(action))
        defer {
            logging(logger, .stopsProcessing(action))
        }
        
        let _dispatch: @Sendable (Action) async -> Void = { dispatchingAction in
            logging(logger, .dispatching(action))
            await dispatch(dispatchingAction)
        }
        
        let _currentState: @Sendable () async -> State = {
            let currentState = await currentState()
            logging(logger, .receiving(currentState))
            return currentState
        }
        await middleware.process(action, in: _currentState, dispatch: _dispatch)
    }
    
    public enum Context {
        case startsProcessing(Middleware.Action)
        case stopsProcessing(Middleware.Action)
        case dispatching(Middleware.Action)
        case receiving(Middleware.State)
    }
}

extension MiddlewareProtocol {
    public func logEvents<Logger>(
        with logger: Logger,
        _ log: @Sendable @escaping (Logger, LoggerMiddleware<Self, Logger>.Context) -> Void
    ) -> LoggerMiddleware<Self, Logger> {
        LoggerMiddleware(logger: logger, logging: log, middleware: self)
    }
}
