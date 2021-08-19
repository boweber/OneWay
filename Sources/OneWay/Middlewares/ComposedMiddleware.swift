public struct ComposedMiddleware<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>: MiddlewareProtocol where LHS.Action == RHS.Action, LHS.State == RHS.State {
    private let storage: Storage

    init?(_ lhsmiddleware: LHS?, _ rhsmiddleware: RHS?) {
        switch (lhsmiddleware, rhsmiddleware) {
        case let (.some(lhs), .some(rhs)):
            self.storage = .tuple(lhs: lhs, rhs: rhs)
        case let (.some(lhs), .none):
            self.storage = .singleLHS(lhs)
        case let (.none, .some(rhs)):
            self.storage = .singleRHS(rhs)
        default:
            return nil
        }
    }
    
    public func process(
        _ action: LHS.Action,
        in currentState: @Sendable @escaping () async -> LHS.State,
        dispatch: @Sendable @escaping (LHS.Action) async -> Void
    ) async {
        switch storage {
        case .singleLHS(let lhs):
            await lhs.process(action, in: currentState, dispatch: dispatch)
        case .singleRHS(let rhs):
            await rhs.process(action, in: currentState, dispatch: dispatch)
        case .tuple(let lhs, let rhs):
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await lhs.process(action, in: currentState, dispatch: dispatch)
                }
                group.addTask {
                    await rhs.process(action, in: currentState, dispatch: dispatch)
                }
            }
        }
    }
    
    private enum Storage {
        case singleLHS(LHS)
        case singleRHS(RHS)
        case tuple(lhs: LHS, rhs: RHS)
    }
}

