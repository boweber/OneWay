import OneWay
import Benchmark

struct BenchmarkMiddleware: MiddlewareProtocol {
    func process(
        _ action: Bool,
        in currentState: @Sendable @escaping () async -> Int,
        dispatch: @Sendable @escaping (Bool) async -> Void
    ) async {
        if action {
            await dispatch(true)
        } else {
            return
        }
    }
}

let store = Store(
    initialState: 1,
    middleware: BenchmarkMiddleware()
) { action, state in
    if action {
        state = state + 1
    } else {
        state = 0
    }
}
