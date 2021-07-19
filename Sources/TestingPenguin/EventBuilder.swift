@resultBuilder
public struct EventBuilder<Action, State> {
    public static func buildBlock(_ components: Event<Action, State>...) -> [Event<Action, State>] {
        components
    }
}
