import Vapor


import Fluent








func
routes(_ inApp: Application)
	throws
{
	inApp.group("api")
	{ inAPIGroup in
		inAPIGroup.group("players")
		{ inGroup in
			try! inGroup.register(collection: PlayersController())
		}
		
		inAPIGroup.get("games")
		{ inReq in
			let dbGames = try await Game
										.query(on: inReq.db)
										.with(\.$words)
										.all()
			let games = try dbGames
							.map
							{ inGame in
								let words = try inGame.words.map { try GameWordDTO(id: $0.requireID(), word: $0.word) }
								let game = try GameDTO(id: inGame.requireID(), name: inGame.name, words: words)
								return game
							}
			return games
		}
	}
}









struct
GameDTO : Content
{
	var	id			:	UUID
	var	name		:	String
	var	words		:	[GameWordDTO]
}

struct
GameWordDTO : Content
{
	var	id			:	UUID
	var	word		:	String
}
