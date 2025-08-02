//
//  CardsController.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-02.
//

import Fluent
import Logging
import Vapor






struct
CardsController : RouteCollection
{
    func
    boot(routes inRoutes: any RoutesBuilder)
    	throws
	{
		inRoutes.get(":id", use: getCard)
	}
	
	func
	getCard(_ inReq: Request)
		async
		throws
		-> CardDTO
	{
		let cardIDStr = inReq.parameters.get("id")!
		guard
			let cardID = UUID(uuidString: cardIDStr)
		else
		{
			throw ApplicationError.invalidID(cardIDStr)
		}
		
		return try await inReq.db.transaction
		{ inTxn in
			guard
				let card = try await Card.find(id: cardID, on: inTxn)
			else
			{
				throw ApplicationError.notFound("Card ID \(cardIDStr) not found.")
			}
			return try CardDTO(card: card)
		}
	}
}




struct
CardDTO : Content
{
	var	id			:	UUID
	var	gameID		:	UUID
	var	playerID	:	UUID
	var	words		:	[CardWordDTO]
}

struct
CardWordDTO : Content
{
	var	id			:	UUID
	var	sequence	:	Int
	var	word		:	String
	var	marked		:	Bool?
}

extension
CardDTO
{
	init(card: Card)
		throws
	{
		self.id = try card.requireID()
		self.gameID = card.$game.id
		self.playerID = card.$player.id
		self.words = try card.words
							.sorted(by: { $0.sequence < $1.sequence })
							.map { try CardWordDTO(cardWord: $0) }
	}
}

extension
CardWordDTO
{
	init(cardWord: CardWord)
		throws
	{
		self.id = try cardWord.requireID()
		self.sequence = cardWord.sequence
		self.word = cardWord.word.word
		self.marked = cardWord.marked
	}
}
