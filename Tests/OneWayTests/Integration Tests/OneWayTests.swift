import XCTest
import TestingOneWay
@testable import OneWay

final class OneWayTests: XCTestCase {
    
    func createStore(
        injectedError: Error? = nil
    ) -> Store<BaseMiddleware<GlobalAction, GlobalState>> {
        SongTests
            .createSongStore(injectedError: injectedError)
            .lift(input: \GlobalAction.songAction, state: \GlobalState.song, output: GlobalAction.songAction) +
        ToDoTests
            .createToDoStore()
            .lift(input: \GlobalAction.todoAction, state: \GlobalState.todo, output: GlobalAction.todoAction)
            
    }
    
    func testGettingFavouriteSongInGlobalContext() async {
        await AssertStates(
            in: createStore(),
            for: .songAction(.requestFavouriteSong),
            [
                .init(todo: .initial, song: .loading),
                .init(todo: .initial, song: .loaded(.blueworld))
            ]
        )
    }
    
    func testGettingToDosInGlobalContext() async {
        await Assert(in: createStore(), [
            .dispatch(.todoAction(.loadToDos)),
            .expect(.loading, in: \.todo),
            .expect(.received(ToDo.examples(count: 1)), in: \.todo),
            .expect(.received(ToDo.examples(count: 2)), in: \.todo),
            .expect(.received(ToDo.examples(count: 3)), in: \.todo)
        ])
    }
    
    func testConcurrentDispatches() async {
        let store = createStore()
        let receivedStateChanges: Task<[GlobalState], Never> = Task {
            var states: [GlobalState] = []
            for await state in store.currentState {
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
