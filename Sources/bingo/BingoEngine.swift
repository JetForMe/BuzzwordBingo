//
//  Bingo.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-02.
//

import Fluent
import Logging



/**
	Coordinates game events and logic.
*/

actor
BingoEngine
{
	typealias	GameUpdateHandler		=	(UUID, UUID, Int, Bool) throws -> ()
	
	
	init(db: any Database)
	{
		self.db = db
	}
	
	/**
		Call within a transaction.
	*/
	
	func
	mark(cardID inCardID: UUID, sequence inSequence: Int, mark inMark: Bool, on inDB: any Database)
		async
		throws
		-> CardWord
	{
		//	TODO: Check to see if the game is finished?
		
		//	Get the CardWord…
		
		guard
			let card = try await Card.find(id: inCardID, on: inDB),
			inSequence < card.words.count
		else
		{
			throw ApplicationError.notFound("CardWord for CardID \(inCardID.uuidString) and sequence \(inSequence) not found.")
		}
		
		//	Mark the word…
		
		let cw = card.words[inSequence]
		cw.marked = inMark
		Self.logger.info("Marked card: \(inMark)")
		//	TODO: Test for bingo and broadcast.
		
		try await cw.save(on: inDB)
		
		let gameID = card.$game.id
		if let clients = self.clients[gameID]
		{
			for (_, handler) in clients
			{
				try? handler(gameID, inCardID, inSequence, inMark)
			}
		}
		return cw
	}
	
	func
	onUpdate(gameID: UUID, clientID: UUID, handler: @escaping GameUpdateHandler)
		async
	{
		var clients = self.clients[gameID]
		if clients == nil
		{
			clients = [:]
			self.clients[gameID] = clients
		}
		
		self.clients[gameID]![clientID] = handler
	}
	
	func
	remove(gameID: UUID, clientID: UUID)
	{
		self.clients[gameID]?.removeValue(forKey: clientID)
	}
	
	
	let	db						:	any Database
	
	/**
		The map of clients is [ Game ID : [ WebSocket ID : Handler ]]
	*/
	
	var	clients											=	[UUID : [UUID : GameUpdateHandler]]()
	
	
	
	static	let	logger									=	Logger(label: "Bingo")
}
