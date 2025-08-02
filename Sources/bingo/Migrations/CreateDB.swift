//
//  CreateDB.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//


import Fluent











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
						.field(.gameID, .uuid, .references(Game.schema, .id, onDelete: .setNull), .required)
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
						.field(.gameID, .uuid, .references(Game.schema, .id, onDelete: .setNull), .required)
						.field(.playerID, .uuid, .references(Player.schema, .id, onDelete: .setNull), .required)
						.unique(on: .gameID, .playerID)
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
						.field(.cardID, .uuid, .references(Card.schema, .id, onDelete: .setNull), .required)
						.field(.wordID, .uuid, .references(GameWord.schema, .id, onDelete: .setNull), .required)
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


