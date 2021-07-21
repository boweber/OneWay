/// A `Reducer` is a function that updates the current state based on an action.
///
/// As an example, consider the situation requesting a favourite song. The type `Action` might be
/// ```
/// enum SongAction {
///     case requestFavouriteSong
///     case load(Song)
///     case fail(Error)
/// }
/// ```
/// with the corresponding `State` type
/// ```
/// enum SongState {
///     case initial
///     case loading
///     case favouriteSong(Song)
///     case failed(Error)
/// }
/// ```
/// . The accompanying  `Reducer` can be defined as
/// ```
/// let songreducer: Reducer<SongAction, SongState> = { action, mutableState in
///     switch action {
///     case .requestFavouriteSong:
///         mutableState = .loading
///     case .load(let song):
///         mutableState = .favouriteSong(song)
///     case .fail(let error):
///         mutableState = .failed(error)
///     }
/// }
/// ```
/// . An important point of the reducer is not to handle any async functionality. For example, the above reducer does not perform the favourite song request by itself. These types
/// of tasks are the responsibilities of an accompanying middleware, which dispatches the actions like `.load(someFavouriteSongExample)` and `.fail(someError)`.
///
/// For more, see [Writing Reducers](https://redux.js.org/tutorials/fundamentals/part-3-state-actions-reducers#writing-reducers)
/// from *redux.js.org*. Note, the reducer does not create a new state as *redux.js.org* encourages, but it rather mutates the state due to performance reasons.
public typealias Reducer<Action, State> = (Action, inout State) -> Void
