import Vapor


import Fluent








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
}









