public protocol MiddlewareProtocol {
    associatedtype Action: Sendable
    associatedtype State: Sendable
    
    func process(_ action: Action, in currentState: @Sendable @escaping () async -> State, dispatch: @Sendable @escaping (Action) async -> Void) async
}
