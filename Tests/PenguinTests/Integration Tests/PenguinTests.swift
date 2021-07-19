import XCTest
import TestingPenguin
@testable import Penguin

final class PenguinTests: XCTestCase {
    
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
}
