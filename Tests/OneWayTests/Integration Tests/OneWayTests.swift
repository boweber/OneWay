import XCTest
import TestingOneWay
@testable import OneWay

final class OneWayTests: XCTestCase {
    
    func createPipeline(
        injectedError: Error? = nil
    ) -> Pipeline<
        ComposedMiddleware<
            LiftedMiddleware<GlobalAction, GlobalState, LoggerMiddleware<SongMiddleware>>,
            LiftedMiddleware<GlobalAction, GlobalState, TodoMiddleware>
        >
    > {
        Pipeline {
            SongTests
                .createSongPipeline(injectedError: injectedError)
                .lifted(input: \GlobalAction.songAction, output: GlobalAction.songAction, state: \GlobalState.song)
            ToDoTests
                .createToDoPipeline()
                .lifted(input: \GlobalAction.todoAction, output: GlobalAction.todoAction, state: \GlobalState.todo)
        }
    }
    
    func testGettingFavouriteSongInGlobalContext() async {
        await AssertStates(
            in: createPipeline(),
            with: .initial,
            for: .songAction(.requestFavouriteSong),
            [
                .init(todo: .initial, song: .loading),
                .init(todo: .initial, song: .loaded(.blueworld))
            ]
        )
    }
    
    func testGettingToDosInGlobalContext() async {
        await Assert(in: createPipeline(), with: .initial, [
            .dispatch(.todoAction(.loadToDos)),
            .expect(.loading, in: \.todo),
            .expect(.received(ToDo.examples(count: 1)), in: \.todo),
            .expect(.received(ToDo.examples(count: 2)), in: \.todo),
            .expect(.received(ToDo.examples(count: 3)), in: \.todo)
        ])
    }
    
    func testConcurrentDispatches() async {
        let store = Store(initialState: .initial, pipeline: createPipeline())
        let receivedStateChanges: Task<[GlobalState], Never> = Task {
            var states: [GlobalState] = []
            for await state in await store.currentState {
                states.append(state)
                if states.count == 6 { break }
            }
            return states
        }
        Task(priority: .background) {
            await store.dispatch(.todoAction(.loadToDos), priority: Task.currentPriority)
        }
        Task(priority: .high) {
            await store.dispatch(.songAction(.requestFavouriteSong), priority: Task.currentPriority)
        }
        
        let storeChanges = await receivedStateChanges.value
        XCTAssertEqual(6, storeChanges.count)
        XCTAssertEqual(storeChanges.last?.song, SongState.loaded(.blueworld))
        XCTAssertEqual(storeChanges.last?.todo, TodoState.received(ToDo.examples))
    }
}
