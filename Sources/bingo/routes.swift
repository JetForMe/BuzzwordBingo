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
	inApp.get
	{ inReq async throws -> View in
		return try await inReq.view.render("index")
	}
	
	inApp.get("games")
	{ inReq async throws -> View in
		let games = try await GamesController().getGames(inReq)
		return try await inReq.view.render("games", [ "games" : games ])
	}
}









