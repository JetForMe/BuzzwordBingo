//
//  Card.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

import Foundation

import Fluent





final
class
Card : Model, @unchecked Sendable
{
	static let schema = "Card"
	
	@ID(key: .id)					var id				:	UUID?
	@Parent(key: .gameID)			var game			:	Game
	@Parent(key: .playerID)			var player			:	Player
	@Children(for: \.$card)			var words			:	[CardWord]
	
	init() {}
	
	init(id: UUID? = nil, game: Game, player: Player)
	{
		self.id = id
		self.$game.id = game.id!
		self.$game.value = game
		self.$player.id = player.id!
		self.$player.value = player
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
		self.$card.value = card
		self.$word.id = word.id!
		self.$word.value = word
		self.sequence = sequence
		self.marked = marked
	}
}




extension
Card
{
	static
	func
	find(id inID: UUID, on inDB: any Database)
		async
		throws
		-> Card?
	{
		let result = try await Card
								.query(on: inDB)
								.filter(\.$id == inID)
								.with(\.$words) { $0.with(\.$word) }
								.first()
		
		return result
	}
	
	/**
		Returns the ``Card`` for the given ``gameID`` and ``playerID``.
	*/
	
	static
	func
	find(gameID inGameID: UUID, playerID inPlayerID: UUID, on inDB: any Database)
		async
		throws
		-> [Card]
	{
		let result = try await Card
								.query(on: inDB)
								.filter(\.$game.$id == inGameID)
								.filter(\.$player.$id == inPlayerID)
								.with(\.$words) { $0.with(\.$word) }
								.all()
		
		return result
	}
}



extension
CardWord
{
	/**
		Returns the ``CardWord`` for the given ``cardID`` and ``sequence``.
	*/
	
	static
	func
	find(cardID inCardID: UUID, sequence inSequence: Int, on inDB: any Database)
		async
		throws
		-> CardWord?
	{
		let result = try await CardWord
								.query(on: inDB)
								.filter(\.$card.$id == inCardID)
								.filter(\.$sequence == inSequence)
								.with(\.$word)
								.first()
		
		return result
	}
}
