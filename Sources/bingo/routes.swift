import Vapor


import Fluent
import Leaf







func
routes(_ inApp: Application)
	throws
{
	inApp.group("api")
	{ inAPIGroup in
		inAPIGroup.group("cards")
		{ inGroup in
			try! inGroup.register(collection: CardsController())
		}
		
		inAPIGroup.group("games")
		{ inGroup in
			try! inGroup.register(collection: GamesController())
		}
		
		inAPIGroup.group("players")
		{ inGroup in
			try! inGroup.register(collection: PlayersController())
		}
	}
	
//	inApp.get
//	{ inReq in
//		sLogger.info("public dir: \(publicDir)")
//		let indexPath = publicDir / "index.html"
//		return try await inReq.fileio.asyncStreamFile(at: indexPath.string)
//	}

	try! inApp.register(collection: ViewsController())
	
//	inApp.get
//	{ inReq async throws -> View in
//	}
//	
//	inApp.get("games")
//	{ inReq async throws -> View in
//		let games = try await GamesController().getGames(inReq)
//		let leafContext = LeafTemplateContext(currentPlayer: inReq.player, games: games)
//		return try await inReq.view.render("games", leafContext)
//	}
//	
//	inApp.get("games", ":nameOrID")
//	{ inReq async throws -> View in
//		let nameOrID = inReq.parameters.get("nameOrID")!
//		
//		guard
//			let dbGame = try await Game.find(nameOrID: nameOrID, on: inReq.db)
//		else
//		{
//			throw ApplicationError.notFound("Game \(nameOrID) not found")
//		}
//		
//		let game = try GameDTO(game: dbGame)
//		let card = try await GamesController().getPlayerCard(inReq)
//		
//		let leafContext = LeafTemplateContext(currentPlayer: inReq.player, currentGame: game, currentCard: card)
//		return try await inReq.view.render("game", leafContext)
//	}
}

/**
	Catch-all context for Leaf templates.
*/

struct
LeafTemplateContext : Content
{
	var	currentPlayer		:	Player?
	var	currentGame			:	GameDTO?
	var	currentCard			:	CardDTO?
	
	var	games				:	GamesDTO?
}








