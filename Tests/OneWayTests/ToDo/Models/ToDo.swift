struct ToDo: Codable, Sendable, Equatable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
    
    static let examples: [ToDo] = [
        ToDo(id: 1, userId: 1, title: "delectus aut autem", completed: false),
        ToDo(id: 2, userId: 1, title: "quis ut nam facilis et officia qui", completed: false),
        ToDo(id: 3, userId: 1, title: "fugiat veniam minus", completed: false)
    ]
    
    static func examples(count: Int) -> [ToDo] {
        Array(examples.prefix(count))
    }
}
