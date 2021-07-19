import Foundation
import Penguin

struct TodoMiddleware: MiddlewareProtocol {    
    func process(_ action: TodoAction, in currentState: @Sendable @escaping () async -> TodoState, dispatch: @Sendable @escaping (TodoAction) async -> Void) async {
        let url = Bundle.module.url(forResource: "Todo", withExtension: "json")!
        do {
            let handler = try FileHandle(forReadingFrom: url)
            for try await line in handler.bytes.lines {
                let todo = try JSONDecoder().decode(ToDo.self, from: Data(line.utf8))
                await dispatch(.receive(todo))
            }
        } catch {
            await dispatch(.failed(error))
        }
    }
}
