@resultBuilder
public struct PipelineBuilder<Middleware: MiddlewareProtocol> {
    public static func buildBlock<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>(
        _ middleware: LHS,
        _ pipeline: Pipeline<RHS>
    ) -> Pipeline<Middleware> where LHS.Action == RHS.Action, LHS.State == RHS.State, Middleware == ComposedMiddleware<LHS, RHS> {
        Pipeline<ComposedMiddleware<LHS, RHS>>(
            middleware: ComposedMiddleware<LHS, RHS>(middleware, pipeline.middleware),
            reducer: pipeline.reducer
        )
    }
    
    public static func buildBlock<LHS: MiddlewareProtocol, RHS: MiddlewareProtocol>(
        _ lhspipeline: Pipeline<LHS>,
        _ rhspipeline: Pipeline<RHS>
    ) -> Pipeline<Middleware> where LHS.Action == RHS.Action, LHS.State == RHS.State, Middleware == ComposedMiddleware<LHS, RHS> {
        Pipeline<ComposedMiddleware<LHS, RHS>>(
            middleware: ComposedMiddleware(lhspipeline.middleware, rhspipeline.middleware)
        ) { action, mutableState in
            lhspipeline.reducer(action, &mutableState)
            rhspipeline.reducer(action, &mutableState)
        }
    }
}
