import XCTest
import TestingPenguin
@testable import Penguin

final class ToDoTests: XCTestCase {
    
    static func createToDoStore(
        dismissedAction: @escaping (TodoAction) -> Void = { _ in },
        stateForEachLine: @escaping (TodoState) -> Void = { _ in }
    ) -> Store<TodoMiddleware> {
        Store(middleware: TodoMiddleware(
            dismissedAction: dismissedAction,
            stateForEachLine: stateForEachLine)
        ) { action, state in
            switch action {
            case .loadToDos: state = .loading
            case .receive(let todo):
                if case .received(var currentToDos) = state {
                    currentToDos.append(todo)
                    state = .received(currentToDos)
                } else {
                    state = .received([todo])
                }
            case .failed(let error):
                state = .failed(error)
            }
        }
    }
    
    func testExample() async throws {
        await AssertStates(
            in: ToDoTests.createToDoStore(),
            for: .loadToDos,
            [
                .loading,
                .received(ToDo.examples(count: 1)),
                .received(ToDo.examples(count: 2)),
                .received(ToDo.examples(count: 3))
            ]
        )
    }
    
    func testCurrentStateInMiddleware() async throws {
        var expectedCurrentState: [TodoState] = [
            .loading,
            .received(ToDo.examples(count: 1)),
            .received(ToDo.examples(count: 2))
        ]
        
        await AssertStates(
            in: ToDoTests.createToDoStore(stateForEachLine: { state in
                XCTAssertEqual(state, expectedCurrentState.removeFirst())
            }),
            for: .loadToDos,
            [
                .loading,
                .received(ToDo.examples(count: 1)),
                .received(ToDo.examples(count: 2)),
                .received(ToDo.examples(count: 3))
            ]
        )
    }
}
