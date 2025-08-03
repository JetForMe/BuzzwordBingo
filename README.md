# Bingo

Super-simple Bingo game webapp.

This work is licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). See LICENSE.md for details.

## Mutating Operations

1. Register
2. Create a Game
3. Start/End a Game
4. Join a Game
5. Mark a cell

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

### 3. Start or End a Game

Should probably add the ability to start, or at least end, a game (so people
can't change it later).


### 4. Join a Game

`PUT /api/games/<gameID>/players` with the `PlayerID`.

This operation is idempotent. A `Card` is created for the game and player
if one does not already exist, and is returned.

### 5. Mark (or Unmark) a Cell

`PUT /api/card/<cardID>/<index>/mark`
`DELETE /api/card/<cardID>/<index>/mark`

On each update, the Player’s marked Card is evaluated for solutions, and
a score update is sent out. The `marked` state is an optional `Bool`. If
it was `nil` before update, then a notification is sent that the plaeyr
got a new solution. If `marked` is not nil when updated, then no notification
is sent.

## Game Logic

On every word mark/unmark, the game logic runs and determines what (if any)
Bingoes the move achieved. Each bingo is recorded as as an entry that includes

	1. Card ID
	2. Bingo type: row, column, corners
	3. An integer representing which row or column has the bingo
	4. Timestamp
	5. Verified flag

When a bingo is detected, it is first looked up, and if it exists, nothing
more is done.

If it's a new bingo, the player’s score is updated a new game update is sent
with the new score(s).

### Removing a Bingo

When a player unmarks a word, existing Bingos relying on it are deleted.
 

## Game Updates

Updates sent over the websocket to clients include:

1. Cell marked/unmarked
2. Player list updated

## Status

When the client joins and displays a game, it:

1. Fetches the player’s card.
2. Opens a websocket on `/api/games/<gameID>`

	On websocket connect, the socket sends:

	1. The current game state (list of players and their scores)


