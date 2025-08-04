//
//  GamesController.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

import Fluent
import Logging
import Vapor






struct
GamesController : RouteCollection
{
    func
    boot(routes inRoutes: any RoutesBuilder)
    	throws
	{
		inRoutes.get(use: getGames)
		inRoutes.get(":nameOrID", use: getGame)
		inRoutes.get(":nameOrID", "card", use: getPlayerCard)
	}
	
	func
	getGames(_ inReq: Request)
		async
		throws
		-> [GameDTO]
	{
		let dbGames = try await Game.getAll(on: inReq.db)
		let games = try dbGames.map { try GameDTO(game: $0) }
		return games
	}
	
	func
	getGame(_ inReq: Request)
		async
		throws
		-> GameDTO
	{
		let nameOrID = inReq.parameters.get("nameOrID")!
		
		return try await inReq.db.transaction
		{ inTxn in
			guard
				let game  = try await Game.find(nameOrID: nameOrID, on: inTxn)
			else
			{
				throw ApplicationError.notFound("Game \(nameOrID) not found")
			}
			
			let words = try game.words.map { try GameWordDTO(id: $0.requireID(), word: $0.word) }
			let dto = try GameDTO(id: game.requireID(), name: game.name, displayName: game.displayName, words: words)
			return dto
		}
	}
	
	/**
		Returns the player’s card for the specified game. The player ID must be
		present in the request headers. Generates a card on first request.
	*/
	
	func
	getPlayerCard(_ inReq: Request)
		async
		throws
		-> CardDTO
	{
		let player = try inReq.requirePlayer()
		
		return try await inReq.db.transaction
		{ inTxn in
			let nameOrID = inReq.parameters.get("nameOrID")!
			guard
				let game  = try await Game.find(nameOrID: nameOrID, on: inTxn)
			else
			{
				throw ApplicationError.notFound("Game \(nameOrID) not found")
			}
			
			if game.words.count == 0
			{
				throw ApplicationError.gameHasNoWords
			}
			
			//	Look up the card. If it doesn’t exist, create a new one…
			
			let card: Card
			let cards = try await Card.find(gameID: game.requireID(), playerID: player.requireID(), on: inTxn)
			if cards.count == 0
			{
				card = Card(game: game, player: player)
				try await card.save(on: inTxn)
				
				var gameWords = game.words
				
				var words = [CardWord]()
				for i in 0 ..< 25
				{
					//	Grab a random word and remove it from the list of available words…
					
					let gameWord = gameWords.randomElement()!
					gameWords.removeAll { $0.id == gameWord.id }
					
					//	Just in case there aren’t enough game words, start over…
					
					if gameWords.isEmpty
					{
						gameWords = game.words
					}
					
					//	Create a CardWord for it…
					
					let cardWord = CardWord(card: card, word: gameWord, sequence: i)
					try await cardWord.save(on: inTxn)
					words.append(cardWord)
				}
				
				card.$words.value = words
			}
			else
			{
				card = cards.first!
			}
			
			return try CardDTO(card: card)
		}
	}
}




struct
GameDTO : Content
{
	var	id			:	UUID
	var	name		:	String
	var	displayName	:	String
	var	words		:	[GameWordDTO]
	
	init(id: UUID, name: String, displayName: String, words: [GameWordDTO])
	{
		self.id = id
		self.name = name
		self.displayName = displayName
		self.words = words
	}
	
	init(game inGame: Game)
		throws
	{
		let words = try inGame.words.map { try GameWordDTO(id: $0.requireID(), word: $0.word) }
		self.init(id: try inGame.requireID(), name: inGame.name, displayName: inGame.displayName, words: words)
	}
}

struct
GameWordDTO : Content
{
	var	id			:	UUID
	var	word		:	String
}
