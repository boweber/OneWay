import XCTest
import Penguin

public enum Event<Action, State> {
    case dispatch(Action)
    case expect((State) throws -> Void)
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
