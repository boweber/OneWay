import Penguin
import XCTest

public func AssertStates<Middleware: MiddlewareProtocol>(
    in store: Store<Middleware>,
    for action: Middleware.Action,
    _ states: [Middleware.State],
    file: StaticString = #file,
    line: UInt = #line
) async where Middleware.State: Equatable {
    guard !states.isEmpty else {
        preconditionFailure("The function \(#function) requires at least on observable state.")
    }
    await store.dispatch(action)
    var expectedStates = states
    var expectedStatesIndex = 0
    for await state in store.currentState {
        let expectedState = expectedStates.removeFirst()
        XCTAssertEqual(
            expectedState,
            state,
            "The state at index \(expectedStatesIndex) is not equal to the observed state.",
            file: file,
            line: line
        )
        if expectedStates.isEmpty {
            
            // Warning: Possible states that can be encountered afterwards are not observed and not tested!
            
            return
        } else {
            expectedStatesIndex = expectedStatesIndex.advanced(by: 1)
        }
    }
}
