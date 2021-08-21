@resultBuilder
public struct PipelineBuilder<Middleware: MiddlewareProtocol> {
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
        _ lhspipeline: Pipeline<LHS>,
        _ rhspipeline: Pipeline<RHS>
    ) -> Pipeline<ComposedMiddleware<LHS, RHS>> where LHS.Action == RHS.Action, LHS.State == RHS.State {
        Pipeline(middleware: ComposedMiddleware(lhspipeline.middleware, rhspipeline.middleware)) { action, mutableState in
            lhspipeline.reducer(action, &mutableState)
            rhspipeline.reducer(action, &mutableState)
        }
    }
}
