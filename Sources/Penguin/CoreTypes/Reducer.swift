public typealias Reducer<Action, State> = (Action, inout State) -> Void
