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
		
		inAPIGroup.group("games")
		{ inGroup in
			try! inGroup.register(collection: GamesController())
		}
	}
}









