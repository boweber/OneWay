@resultBuilder
public struct PipelineBuilder {
    public static func buildBlock<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>(
        _ middleware: LHS,
        _ pipeline: Pipeline<RHS>
    ) -> Pipeline<ComposedMiddleware<LHS, RHS>> where LHS.Action == RHS.Action, LHS.State == RHS.State {
        Pipeline(
            middleware: ComposedMiddleware(middleware, pipeline.middleware),
            reducer: pipeline.reducer
        )
    }
    
    public static func buildBlock<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>(
        _ middleware: LHS,
        _ pipeline: Pipeline<RHS>
    ) -> Pipeline<ComposedMiddleware<LiftedMiddleware<LHS.Action, RHS.State, LHS>, RHS>> where LHS.Action == RHS.Action, LHS.State == Never {
        Pipeline(
            middleware: ComposedMiddleware(middleware.liftState(to: RHS.State.self), pipeline.middleware),
            reducer: pipeline.reducer
        )
    }
    
    public static func buildBlock<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>(
        _ lhs: Pipeline<LHS>,
        _ rhs: Pipeline<RHS>
    ) -> Pipeline<ComposedMiddleware<LHS, RHS>> where LHS.Action == RHS.Action, LHS.State == RHS.State {
        Pipeline(middleware: ComposedMiddleware(lhs.middleware, rhs.middleware)) { action, mutableState in
            lhs.reducer(action, &mutableState)
            rhs.reducer(action, &mutableState)
        }
    }
}
