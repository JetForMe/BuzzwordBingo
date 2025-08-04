//
//  CreateDB.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//


import Fluent







struct
CreateEnums: AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		//	BingoType enum…

		var stateEB = inDB.enum(String(describing: Bingo.BingoType.self))
		for c in Bingo.BingoType.allCases
		{
			stateEB = stateEB.case(c.rawValue)
		}
		let _ = try await stateEB.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.enum(String(describing: Bingo.BingoType.self)).delete()
	}
}





struct
CreateGame: AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Game.schema)
						.id()
						.field(.ownerID, .uuid, .references(Player.schema, .id, onDelete: .cascade), .required)
						.field(.name, .string, .required)
						.field(.displayName, .string, .required)
						.field(.created, .date, .required)
						.unique(on: .name)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Game.schema).delete()
	}
}


struct
CreateGameWord: AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(GameWord.schema)
						.id()
						.field(.gameID, .uuid, .references(Game.schema, .id, onDelete: .cascade), .required)
						.field(.word, .string, .required)
						.unique(on: .gameID, .word)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(GameWord.schema).delete()
	}
}


struct
CreatePlayer: AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Player.schema)
						.id()
						.field(.name, .string, .required)
						.field(.username, .string, .required)
						.unique(on: .name)
						.unique(on: .username)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Player.schema).delete()
	}
}


struct
CreateCard : AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Card.schema)
						.id()
						.field(.gameID, .uuid, .references(Game.schema, .id, onDelete: .cascade), .required)
						.field(.playerID, .uuid, .references(Player.schema, .id, onDelete: .cascade), .required)
						.unique(on: .gameID, .playerID)			//	TODO: Forces a single card per game, do we want this constraint?
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Card.schema).delete()
	}
}



struct
CreateCardWord : AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(CardWord.schema)
						.id()
						.field(.cardID, .uuid, .references(Card.schema, .id, onDelete: .cascade), .required)
						.field(.wordID, .uuid, .references(GameWord.schema, .id, onDelete: .cascade), .required)
						.field(.sequence, .int, .required)
						.field(.marked, .bool)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(CardWord.schema).delete()
	}
}


struct
CreatePlayerScore : AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(PlayerScore.schema)
						.id()
						.field(.gameID, .uuid, .references(Game.schema, .id, onDelete: .cascade), .required)
						.field(.playerID, .uuid, .references(Player.schema, .id, onDelete: .cascade), .required)
						.field(.score, .int, .required)
						.unique(on: .gameID, .playerID)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(PlayerScore.schema).delete()
	}
}


struct
CreateBingo : AsyncMigration
{
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		let tEB = inDB.enum(String(describing: Bingo.BingoType.self))		//	TODO: Do we want to write this in the log?
		let tType = try await tEB.read()
		
		try await inDB.schema(Bingo.schema)
						.id()
						.field(.cardID, .uuid, .references(Card.schema, .id, onDelete: .cascade), .required)
						.field(.type, tType, .required)
						.field(.index, .int)
						.field(.timestamp, .datetime, .required)
						.unique(on: .cardID, .type, .index)
						.create()
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		try await inDB.schema(Bingo.schema).delete()
	}
}

