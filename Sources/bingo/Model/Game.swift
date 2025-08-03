//
//  Game.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//

import Foundation

import Fluent




struct
CreateEnums: AsyncMigration
{
	func
	prepare(on inDB: Database)
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
	revert(on inDB: Database)
		async
		throws
	{
		try await inDB.enum(String(describing: Bingo.BingoType.self)).delete()
	}
}



final
class
Game : Model, @unchecked Sendable
{
	static let schema = "Game"
	
	@ID(key: .id)					var id				:	UUID?
	@Field(key: .name)				var name			:	String
	@Field(key: .displayName)		var displayName		:	String
	@Field(key: .created)			var created			:	Date
	@Children(for: \.$game)			var words			:	[GameWord]
	
	init() {}
	
	init(
		id: UUID? = nil,
		displayName: String,
		created: Date = Date())
	{
		self.id = id
		self.displayName = displayName
		self.name = displayName.toUsername()
		self.created = created
	}
}


final
class
GameWord : Model, @unchecked Sendable
{
	static let schema = "GameWord"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .gameID)			var game			:	Game
	@Field(key: .word)				var word			:	String
	
	init() {}
	
	init(id: UUID? = nil, game: Game, word: String)
	{
		self.id = id
		self.$game.id = game.id!
		self.$game.value = game
		self.word = word
	}
}

final
class
PlayerScore : Model, @unchecked Sendable
{
	static let schema = "PlayerScore"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .gameID)			var game			:	Game
	@Parent(key: .playerID)			var player			:	Player
	@Field(key: .score)				var score			:	Int
	
	init() {}
	
	init(id: UUID? = nil, game: Game, player: Player, score: Int)
	{
		self.id = id
		self.game = game
		self.player = player
		self.score = score
	}
}


final
class
Bingo : Model, @unchecked Sendable
{
	enum
	BingoType : String, Codable, CaseIterable
	{
		case row
		case column
		case ulbr					//	Diagonal from upper-left to bottom-right
		case llur					//	Diagonal from lower-left to upper-right
		case corners
	}
	
	static let schema = "Bingo"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .cardID)			var card			:	Card
	@Enum(key: .type)				var	type			:	BingoType
	@Field(key: .index)				var index			:	Int
	@Field(key: .timestamp)			var timestamp		:	Date
	@Field(key: .verified)			var verified		:	Bool?
	
//	init() {}
	
}




extension
Game
{
	static
	func
	getAll(on inDB: any Database)
		async
		throws
		-> [Game]
	{
		let result = try await Game
								.query(on: inDB)
								.with(\.$words)
								.all()
		return result
	}
	
	static
	func
	find(id inID: UUID, on inDB: any Database)
		async
		throws
		-> Game?
	{
		let result = try await Game
								.query(on: inDB)
								.filter(\.$id == inID)
								.with(\.$words)
								.first()
		return result
	}
	
	static
	func
	find(displayName inDisplayName: String, on inDB: any Database)
		async
		throws
		-> Game?
	{
		let name = inDisplayName.toUsername()
		let result = try await Game
								.query(on: inDB)
								.filter(\.$name == name)
								.with(\.$words)
								.first()
		return result
	}
	
	static
	func
	find(nameOrID inNameOrID: String, on inDB: any Database)
		async
		throws
		-> Game?
	{
		if let gameID = UUID(uuidString: inNameOrID)
		{
			return try await Game.find(id: gameID, on: inDB)
		}
		else
		{
			return try await Game.find(displayName: inNameOrID, on: inDB)
		}
	}
}
