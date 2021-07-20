import Foundation
import Penguin

struct TodoMiddleware: MiddlewareProtocol {
    let dismissedAction: (TodoAction) -> Void
    let stateForEachLine: (TodoState) -> Void
    
    func process(_ action: TodoAction, in currentState: @Sendable @escaping () async -> TodoState, dispatch: @Sendable @escaping (TodoAction) async -> Void) async {
        guard case .loadToDos = action else {
            dismissedAction(action)
            return
        }
        let url = Bundle.module.url(forResource: "Todo", withExtension: "json")!
        do {
            for try await line in url.lines {
                stateForEachLine(await currentState())
                let todo = try JSONDecoder().decode(ToDo.self, from: Data(line.utf8))
                await dispatch(.receive(todo))
            }
        } catch {
            await dispatch(.failed(error))
        }
    }
}
