import XCTest
import TestingPenguin
@testable import Penguin

final class SongTests: XCTestCase {
    
    static func createSongStore(
        dismissedAction: @escaping (SongAction) -> Void = { _ in },
        requestingState: @escaping (SongState) -> Void = { _ in },
        injectedError: Error? = nil
    ) -> Store<LoggerMiddleware<SongMiddleware, SongLogger>> {
        Store(
            middleware: SongMiddleware(dismissedAction: dismissedAction, state: requestingState, error: injectedError)
                .logEvents(with: SongLogger())
        ) { action, mutableState in
                switch action {
                case .requestFavouriteSong:
                    mutableState = .loading
                case .load(let song):
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
        let dummyError = NSError(domain: "Testing", code: 1, userInfo: [:])
        await Assert(in: SongTests.createSongStore(injectedError: dummyError), [
            .dispatch(.requestFavouriteSong),
            .expect(.loading),
            .expect(.failed(dummyError))
        ])
    }
}
