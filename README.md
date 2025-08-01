# Bingo

Super-simple Bingo game webapp.

## Mutating Operations

1. Register
2. Create a Game
3. Join a Game
4. Mark a cell

### 1. Registration

Registration is dead simple. If the client has no stored user ID, then
it presents a Registration/Login form that asks the user for their
username. This is POSTed to `/api/login`, and it looks up the `Player` by
the username, creating a new one if necessary, and returns the `PlayerID`
(and more).

### 2. Game Creation/Editing

To create a game, POST to `/api/games` a word list and game name.

To edit a game, PUT to `/api/games/<gameID>` with a word list. If the
word list is different than the existing list, all existing `Card`s (and `CardWord`s) are
deleted and new ones created.

> **TODO:** Preserve marked words?

### 3. Join a Game

`PUT /api/games/<gameID>/players` with the `PlayerID`.

This operation is idempotent. A `Card` is created for the game and player
if one does not already exist, and is returned.

### 4. Mark (or Unmark) a Cell

`PUT /api/card/<cardID>/<index>/mark`
`DELETE /api/card/<cardID>/<index>/mark`

On each update, the Player’s marked Card is evaluated for solutions, and
a score update is sent out. The `marked` state is an optional `Bool`. If
it was `nil` before update, then a notification is sent that the plaeyr
got a new solution. If `marked` is not nil when updated, then no notification
is sent.

## Status

When the client joins and displays a game, it:

1. Fetches the player’s card.
2. Opens a websocket on `/api/games/<gameID>`

	On websocket connect, the socket sends:

	1. The current game state (list of players and their scores)


