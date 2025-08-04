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
		inRoutes.get(":id", "words", ":sequence", use: getCardWord)
		inRoutes.put(":id", "words", ":sequence", use: updateCardWord)
		
		inRoutes.webSocket(":id", "updates")
		{ inReq, inWS in
			do
			{
				//	Validate the cardID…
				
				let cardIDStr = inReq.parameters.get("id")!
				guard
					let cardID = UUID(uuidString: cardIDStr),
					let card = try await Card.find(id: cardID, on: inReq.db)
				else
				{
					Self.logger.error("Bad websocket cardID: \(cardIDStr)")
					try await inWS.send("{ \"msg\" : \"Bad websocket cardID: \(cardIDStr)\" }")
					return
				}
				
				//	On connect, set up handlers…
				
				let wsID = UUID()		//	Create a unique ID for this client websocket
				
				Self.logger.info("Websocket conencted client \(wsID.uuidString) for cardID \(cardID.uuidString)")
				
				inWS.onClose.whenComplete
				{ _ in
					Self.logger.info("Websocket disconnected for cardID \(cardID.uuidString)")
					//	TODO: remove from Bingo…
				}
				
				inWS.onText
				{ inWS, inText async in
					Self.logger.info("Websocket received for cardID \(cardID.uuidString): \(inText)")
				}
				
				//	Respond to game events…
				
				await inReq.bingo.onUpdate(gameID: card.$game.id, clientID: wsID)
				{ inGameID, inCardID, inSequence, inMarked in
					Self.logger.info("Got game update for client \(wsID.uuidString)")
					
					let event = GameEvent(gameID: inGameID, cardID: inCardID, sequence: inSequence, marked: inMarked)
					let data = try JSONEncoder().encode(event)
					let jsonString = String(data: data, encoding: .utf8)!
					inWS.send(jsonString)
				}
			}
			
			catch
			{
				Self.logger.error("Unable to set up socket: \(error)")
			}
		}
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
				throw ApplicationError.notFound("Card ID \(cardID.uuidString) not found.")
			}
			return try CardDTO(card: card)
		}
	}
	
	func
	getCardWord(_ inReq: Request)
		async
		throws
		-> CardWordDTO
	{
		let cardIDStr = inReq.parameters.get("id")!
		guard
			let cardID = UUID(uuidString: cardIDStr)
		else
		{
			throw ApplicationError.invalidID(cardIDStr)
		}
		let sequenceStr = inReq.parameters.get("sequence")!
		guard
			let sequence = Int(sequenceStr)
		else
		{
			throw ApplicationError.invalidID(sequenceStr)
		}
		
		return try await inReq.db.transaction
		{ inTxn in
			guard
				let cw = try await CardWord.find(cardID: cardID, sequence: sequence, on: inTxn)
			else
			{
				throw ApplicationError.notFound("CardWord for CardID \(cardID.uuidString) and sequence \(sequence) not found.")
			}
			return try CardWordDTO(cardWord: cw)
		}
	}
	
	func
	updateCardWord(_ inReq: Request)
		async
		throws
		-> UpdateCardWordOpResult
	{
		let cardIDStr = inReq.parameters.get("id")!
		guard
			let cardID = UUID(uuidString: cardIDStr)
		else
		{
			throw ApplicationError.invalidID(cardIDStr)
		}
		
		let sequenceStr = inReq.parameters.get("sequence")!
		guard
			let sequence = Int(sequenceStr)
		else
		{
			throw ApplicationError.invalidID(sequenceStr)
		}
		
		let op = try inReq.content.decode(UpdateCardWordOp.self)
		
		return try await inReq.db.transaction
		{ inTxn in
			//	Check that the player owns the card…
			
			let player = try inReq.requirePlayer()
			
			guard
				let card = try await Card.find(id: cardID, on: inTxn),
				card.$player.id == player.id
			else
			{
				throw ApplicationError.notAuthorized
			}
			
			let cw = try await inReq.bingo.mark(cardID: cardID, sequence: sequence, mark: op.setMarked, on: inTxn)
			let cwDTO = try CardWordDTO(cardWord: cw)
			let result = UpdateCardWordOpResult(status: "OK", cardWord: cwDTO)
			return result
		}
	}
	
	
	static	let	logger				=	Logger(label: "CardsController")
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

struct
UpdateCardWordOp : Content
{
	var	setMarked			:	Bool
}

struct
UpdateCardWordOpResult : Content
{
	var	status				:	String
	var	cardWord			:	CardWordDTO
}

struct
GameEvent : Content
{
	var	gameID				:	UUID
	var	cardID				:	UUID
	var	sequence			:	Int
	var	marked				:	Bool
}
