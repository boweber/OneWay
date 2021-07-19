import XCTest
import TestingPenguin
@testable import Penguin

final class SongTests: XCTestCase {
    
    static func createSongStore(
        dismissedAction: @escaping (SongAction) -> Void = { _ in },
        requestingState: @escaping (SongState) -> Void = { _ in },
        injectedError: Error? = nil
    ) -> Store<SongMiddleware> {
        Store<SongMiddleware>(
            middleware: SongMiddleware(dismissedAction: dismissedAction, state: requestingState, error: injectedError)
        ) { action, mutableState in
                switch action {
                case .requestFavouriteSong:
                    mutableState = .loading
                case .receive(let song):
                    mutableState = .loaded(song)
                case .fail(let error):
                    mutableState = .failed(error)
                }
            }
    }
    
    func testExample() async throws {
        await AssertStates(
            in: SongTests.createSongStore(requestingState: { state in
                
                // The store calls the reducer before the middleware -> state is .loading and not .initial
                
                XCTAssertEqual(state, .loading)
            }),
            for: .requestFavouriteSong,
            [
                .loading,
                .loaded(.blueworld)
            ]
        )
    }
    
    func testExpectingFailure() async {
        await AssertEvents(in: SongTests.createSongStore(injectedError: NSError())) {
            Event<SongAction, SongState>.dispatch(.requestFavouriteSong)
            Event<SongAction, SongState>.expect(.loading)
            Event<SongAction, SongState>.expect(.failed(NSError()))
        }
    }
}
