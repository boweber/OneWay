enum SongAction: Sendable {
    case requestFavouriteSong
    case receive(Song)
    case fail(Error)
}

