@propertyWrapper
public struct Tracing<Element> {
    public let wrappedValue: Element
    public let dispatchDetails: Details?
    public var projectedValue: Tracing<Element> { self }
    
    #if Debug
    public init(
        wrappedValue: Element,
        file: String = #file,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        self.wrappedValue = wrappedValue
        self.dispatchDetails = Details(
            file: file,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column,
            function: function
        )
    }
    #else
    public init(wrappedValue: Element){
        self.wrappedValue = wrappedValue
        self.dispatchDetails = nil
    }
    #endif

    public struct Details {
        public let file: String
        public let fileID: String
        public let filePath: String
        public let line: Int
        public let column: Int
        public let function: String
    }
}
