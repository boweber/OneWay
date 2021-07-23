/// A middleware is responsible to process incoming tasks, which require async functionality.
///
/// For instance, the accompanying task of an incoming action requires a network request.
/// These types of tasks might take a while and a middleware's responsibility is to await the
/// corresponding response(s). After the middleware receives such a response, it can dispatch
/// an action describing or sending the response.
///
/// For more, see [Redux Middleware and Side Effects](https://redux.js.org/tutorials/fundamentals/part-6-async-logic#redux-middleware-and-side-effects)
/// from *redux.js.org*.
public protocol MiddlewareProtocol {
    /// The action handled by this middleware.
    associatedtype Action: Sendable
    /// The associated state of the action handled by this middleware.
    associatedtype State: Sendable
    
    /// Based on an incoming action, the function can start an async task and dispatches its result.
    /// - Parameters:
    ///     - action: An incoming action to process.
    ///     - currentState: A closure to get at any time the current state.
    ///     - dispatch: A closure to send actions, which can be based on the result of an async task.
    func process(_ action: Action, in currentState: @Sendable @escaping () async -> State, dispatch: @Sendable @escaping (Action) async -> Void) async
}
