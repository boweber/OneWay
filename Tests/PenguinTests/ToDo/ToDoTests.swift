import XCTest
import TestingPenguin
@testable import Penguin

final class ToDoTests: XCTestCase {
    
    override func setUp() {}
    
    func createToDoStore() -> Store<TodoMiddleware> {
        Store(middleware: TodoMiddleware()) { action, state in
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
            in: createToDoStore(),
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
