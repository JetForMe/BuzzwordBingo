//
//  Game.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//

import Foundation

import Fluent






final
class
Game : Model, @unchecked Sendable
{
	static let schema = "Game"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .ownerID)			var owner			:	Player
	@Field(key: .name)				var name			:	String
	@Field(key: .displayName)		var displayName		:	String
	@Field(key: .created)			var created			:	Date
	@Children(for: \.$game)			var words			:	[GameWord]
	@Children(for: \.$game)			var scores			:	[PlayerScore]
	
	init() {}
	
	init(id: UUID? = nil,
			ownerID: UUID,
			displayName: String,
			created: Date = Date())
	{
		self.id = id
		self.$owner.id = ownerID
		self.displayName = displayName
		self.name = displayName.toUsername()
		self.created = created
	}
	
	init(id: UUID? = nil,
			owner: Player,
			displayName: String,
			created: Date = Date())
	{
		self.id = id
		self.$owner.id = owner.id!
		self.$owner.value = owner
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
								.with(\.$scores) { $0.with(\.$player) }
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
								.with(\.$scores) { $0.with(\.$player) }
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
	
	static
	func
	find(forPlayerID: UUID, on inDB: any Database)
		async
		throws
		-> [Game]
	{
		let result = try await Game
								.query(on: inDB)
								.filter(\.$owner.$id == forPlayerID)
								.with(\.$words)
								.all()
		return result
	}
}
