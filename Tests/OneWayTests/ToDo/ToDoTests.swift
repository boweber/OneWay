import XCTest
import TestingOneWay
@testable import OneWay

final class ToDoTests: XCTestCase {
    
    static func createToDoPipeline(
        dismissedAction: @escaping (TodoAction) -> Void = { _ in },
        stateForEachLine: @escaping (TodoState) -> Void = { _ in }
    ) -> Pipeline<TodoMiddleware> {
        Pipeline(middleware: TodoMiddleware(
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
            in: ToDoTests.createToDoPipeline(),
            with: .initial,
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
            in: ToDoTests.createToDoPipeline(stateForEachLine: { state in
                XCTAssertEqual(state, expectedCurrentState.removeFirst())
            }),
            with: .initial,
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
