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
	@Field(key: "name")				var name			:	String
	@Field(key: "created")			var created			:	Date
	@Children(for: \.$game)			var words			:	[GameWord]
	
	init() {}
	
	init(
		id: UUID? = nil,
		name: String,
		created: Date = Date())
	{
		self.id = id
		self.name = name
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
	@Field(key: "word")				var word			:	String
	
	init() {}
	
	init(id: UUID? = nil, game: Game, word: String)
	{
		self.id = id
		self.$game.id = game.id!
		self.word = word
	}
}

final
class
Player : Model, @unchecked Sendable
{
	static let schema = "Player"
	
	@ID(key: .id)					var id				:	UUID?
	@Field(key: .name)				var name			:	String
	@Field(key: .username)			var username		:	String
	
	init() {}
	
	init(id: UUID? = nil, name: String)
	{
		self.id = id
		self.name = name
		self.username = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
	}
}


final
class
Card : Model, @unchecked Sendable
{
	static let schema = "Card"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .gameID)			var game			:	Game
	@Parent(key: .playerID)			var player			:	Player
	
	init() {}
	
	init(id: UUID? = nil, game: Game, player: Player)
	{
		self.id = id
		self.$game.id = game.id!
		self.$player.id = player.id!
	}
}


final
class
CardWord : Model, @unchecked Sendable
{
	static let schema = "CardWord"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .cardID)			var card			:	Card
	@Parent(key: .wordID)			var word			:	GameWord
	@Field(key: .sequence)			var sequence		:	Int
	@Field(key: .marked)			var marked			:	Bool?
	
	init() {}
	
	init(id: UUID? = nil, card: Card, word: GameWord, sequence: Int, marked: Bool? = nil)
	{
		self.id = id
		self.$card.id = card.id!
		self.$word.id = word.id!
		self.sequence = sequence
		self.marked = marked
	}
}

