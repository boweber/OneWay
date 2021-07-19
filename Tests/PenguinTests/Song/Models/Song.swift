struct Song: Equatable {
    let title: String
    let artist: String
}

extension Song {
    static let blueworld = Song(title: "Blue World", artist: "Mac Miller")
}
