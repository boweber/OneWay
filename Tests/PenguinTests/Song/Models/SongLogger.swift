import Penguin

struct SongLogger: LoggerProtocol {
    func log(currentState: SongState) {
        print("Requested \(currentState)")
    }
    
    func log(action: SongAction, during context: LoggingContext) {
        switch context {
        case .startsProcessing:
            print("Processing \(action)")
        case .stoppedProcessing:
            print("Finish processing \(action)")
        case .dispatching:
            print("Dispatching \(action)")
        }
    }
}
