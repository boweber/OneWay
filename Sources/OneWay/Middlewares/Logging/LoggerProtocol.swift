public protocol LoggerProtocol {
    associatedtype Action
    associatedtype State

    func log(currentState: State)
    func log(action: Action, during context: LoggingContext)
}

public enum LoggingContext{
    case startsProcessing
    case stoppedProcessing
    case dispatching
}
