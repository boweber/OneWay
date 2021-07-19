import Penguin
import XCTest

public func AssertStates<Middleware: MiddlewareProtocol>(
    in store: Store<Middleware>,
    for action: Middleware.Action,
    _ states: [Middleware.State],
    file: StaticString = #file,
    line: UInt = #line
) async where Middleware.State: Equatable {
    await AssertStates(
        in: store,
        for: action,
        states.map { expectedState -> (Middleware.State) throws -> Void in
            { observedState in
                XCTAssertEqual(expectedState, observedState)
            }
        },
        file: file,
        line: line
    )
}

public func AssertEvents<Middleware: MiddlewareProtocol>(
    in store: Store<Middleware>,
    file: StaticString = #file,
    line: UInt = #line,
    @EventBuilder<Middleware.Action, Middleware.State> _ content: () -> [Event<Middleware.Action, Middleware.State>]
) async {
    var events = content()
    while !events.isEmpty {
        let event = events.removeFirst()
        if case let .dispatch(action) = event {
            let expectedStates: [(Middleware.State) throws -> Void] = events.removeFirstMapableElements { event in
                guard case .expect(let expectation) = event else { return nil }
                return expectation
            }
            await AssertStates(in: store, for: action, expectedStates, file: file, line: line)
        } else {
            preconditionFailure()
        }
    }
}

func AssertStates<Middleware: MiddlewareProtocol>(
    in store: Store<Middleware>,
    for action: Middleware.Action,
    _ states: [(Middleware.State) throws -> Void],
    file: StaticString = #file,
    line: UInt = #line
) async {
    guard !states.isEmpty else {
        preconditionFailure("The function \(#function) requires at least on observable state.")
    }
    
    let observingTask = Task<[Middleware.State], Never> {
        var observedStates: [Middleware.State] = []
        var observedStatesCount = 0
        for await observedState in store.currentState {
            observedStates.append(observedState)
            observedStatesCount = observedStatesCount.advanced(by: 1)
            if observedStatesCount == states.count {
                break
            }
        }
        return observedStates
    }
    await store.dispatch(action)
    var expectedStates = states
    
    for observedState in await observingTask.value {
        if expectedStates.isEmpty {
            
            // This state should not be possible in the current implementation
            // due to line observedStatesCount == expectedStates.count
            
            XCTFail("Unexpected state: \(observedState)", file: file, line: line)
        } else {
            XCTAssertNoThrow(try expectedStates.removeFirst()(observedState), file: file, line: line)
        }
    }
    
    if !expectedStates.isEmpty {
        XCTFail("Unobserved states: \(expectedStates)", file: file, line: line)
    }
}
