enum TodoAction: Sendable {
    case loadToDos
    case receive(ToDo)
    case failed(Error)
}
