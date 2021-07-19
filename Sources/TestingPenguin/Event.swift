import XCTest
import Penguin

public enum Event<Action, State> {
    case dispatch(Action)
    case expect((State) throws -> Void)
    
    var isExpectedStateChange: Bool {
        guard case .expect = self else {
            return false
        }
        return true
    }
    
    func dispatch<Middleware: MiddlewareProtocol>(in store: Store<Middleware>) async where Middleware.Action == Action, Middleware.State == State {
        guard case .dispatch(let action) = self else { return }
        await store.dispatch(action, priority: nil)
    }
}

extension Event {
    public static func expect(
        _ state: State,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self where State: Equatable {
        .expect { XCTAssertEqual(state, $0, file: file, line: line) }
    }
    
    public static func expect<Value>(
        _ value: Value,
        in keyPath: KeyPath<State, Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self where Value: Equatable {
        .expect { XCTAssertEqual(value, $0[keyPath: keyPath], file: file, line: line) }
    }
}
