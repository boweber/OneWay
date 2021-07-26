public struct LoggerMiddleware<Middleware: MiddlewareProtocol, Logger: LoggerProtocol>: MiddlewareProtocol
where Logger.Action == Middleware.Action, Logger.State == Middleware.State {
    let logger: Logger
    let middleware: Middleware
    
    public func process(
        _ action: Middleware.Action,
        in currentState: @Sendable @escaping () async -> Middleware.State,
        dispatch: @Sendable @escaping (Middleware.Action) async -> Void
    ) async {
        logger.log(action: action, during: .startsProcessing)
        defer {
            logger.log(action: action, during: .stoppedProcessing)
        }
        
        let _dispatch: @Sendable (Action) async -> Void = { dispatchingAction in
            logger.log(action: dispatchingAction, during: .dispatching)
            await dispatch(dispatchingAction)
        }
        
        let _currentState: @Sendable () async -> State = {
            let currentState = await currentState()
            logger.log(currentState: currentState)
            return currentState
        }
        await middleware.process(action, in: _currentState, dispatch: _dispatch)
    }
}

extension MiddlewareProtocol {
    public func logEvents<Logger: LoggerProtocol>(with logger: Logger) -> LoggerMiddleware<Self, Logger> where Logger.Action == Action, Logger.State == State {
        LoggerMiddleware(logger: logger, middleware: self)
    }
}
