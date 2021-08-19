import XCTest
import TestingOneWay
@testable import OneWay

final class SongTests: XCTestCase {
    
    static func createSongPipeline(
        dismissedAction: @escaping (SongAction) -> Void = { _ in },
        requestingState: @escaping (SongState) -> Void = { _ in },
        injectedError: Error? = nil
    ) -> Pipeline<LoggerMiddleware<SongMiddleware, SongLogger>> {
        let middleware = SongMiddleware(
            dismissedAction: dismissedAction,
            state: requestingState,
            error: injectedError
        ).logEvents(with: SongLogger())
        
        return Pipeline(middleware: middleware) { action, mutableState in
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
            in: SongTests.createSongPipeline(requestingState: { state in
                
                // The store calls the reducer before the middleware -> state is .loading and not .initial
                
                XCTAssertEqual(state, .loading)
            }),
            with: .initial,
            for: .requestFavouriteSong,
            [
                .loading,
                .loaded(.blueworld)
            ]
        )
    }
    
    func testExpectingFailure() async {
        let dummyError = NSError(domain: "Testing", code: 1, userInfo: [:])
        await Assert(
            in: SongTests.createSongPipeline(injectedError: dummyError),
            with: .initial, [
                .dispatch(.requestFavouriteSong),
                .expect(.loading),
                .expect(.failed(dummyError))
            ])
    }
}
