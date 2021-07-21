enum SongAction: Sendable {
    case requestFavouriteSong
    case load(Song)
    case fail(Error)
}
