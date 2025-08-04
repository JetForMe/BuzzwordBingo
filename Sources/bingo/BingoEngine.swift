//
//  Bingo.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-02.
//

import Foundation

import Fluent
import Logging



/**
	Coordinates game events and logic.
*/

actor
BingoEngine
{
	typealias	GameUpdateHandler		=	(UUID, UUID, Int, Bool, PlayerScore) async throws -> ()
	
	
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
		
		try await cw.save(on: inDB)
		
		//	TODO: Reduce score if word unmarked…
		
		//	Score the card…
		
//		var newBingos = false		//	TODO: Do we need this?
		let bingos = try await findBingos(inCard: card)
		for bingo in bingos
		{
			//	If the Bingo doesn't already exist, save it…
			
			let dbBingo = try await Bingo.find(cardID: card.requireID(), type: bingo.type, index: bingo.index, on: inDB)
			if dbBingo == nil
			{
				try await bingo.save(on: inDB)
//				newBingos = true
			}
		}
		
		var playerScore = try await PlayerScore.find(gameID: card.$game.id, playerID: card.$player.id, on: inDB)
		if playerScore == nil
		{
			playerScore = PlayerScore(gameID: card.$game.id, playerID: card.$player.id, wordScore: 0, bingoScore: 0)
		}
		
		playerScore!.wordScore = card.words.count { $0.marked ?? false }
		playerScore!.bingoScore = bingos.count
		try await playerScore!.save(on: inDB)
		
		//	Notify listeners of the events…
		
		let gameID = card.$game.id
		if let clients = self.clients[gameID]
		{
			//	TODO: task group!
			for (_, handler) in clients
			{
				try? await handler(gameID, inCardID, inSequence, inMark, playerScore!)
			}
		}
		return cw
	}
	
	/**
		Find all bingos in ``card``. The returned
		Bingos are not written to the DB, and will
		need to be deduped by the caller.
	*/
	
	func
	findBingos(inCard: Card)
		async
		throws
		-> [Bingo]
	{
		let now = Date()
		
		var bingos = [Bingo]()
		
		//	Search each row…
		
		let kWidth = 5
		let kHeight = 5
		
		for row in 0 ..< kHeight
		{
			var isBingo = true
			for col in 0 ..< kWidth
			{
				let idx = row * kWidth + col
				if !(inCard.words[idx].marked ?? false)
				{
					isBingo = false
					break
				}
			}
			
			if isBingo
			{
				let bingo = Bingo(card: inCard, type: .row, index: row, timestamp: now)
				bingos.append(bingo)
			}
		}
		
		//	Search each column…
		
		for col in 0 ..< kWidth
		{
			var isBingo = true
			for row in 0 ..< kHeight
			{
				let idx = row * kWidth + col
				if !(inCard.words[idx].marked ?? false)
				{
					isBingo = false
					break
				}
			}
			
			if isBingo
			{
				let bingo = Bingo(card: inCard, type: .column, index: col, timestamp: now)
				bingos.append(bingo)
			}
		}
		
		//	Diagonals…
		
		if kWidth == kHeight
		{
			var isBingo = true
			for d in 0 ..< kWidth
			{
				let idx = d * kWidth + d
				if !(inCard.words[idx].marked ?? false)
				{
					isBingo = false
					break
				}
			}
			
			if isBingo
			{
				let bingo = Bingo(card: inCard, type: .ulbr, timestamp: now)
				bingos.append(bingo)
			}
			
			isBingo = true
			for d in 0 ..< kWidth
			{
				let idx = d * kWidth + (kWidth - d - 1)
				if !(inCard.words[idx].marked ?? false)
				{
					isBingo = false
					break
				}
			}
			
			if isBingo
			{
				let bingo = Bingo(card: inCard, type: .llur, timestamp: now)
				bingos.append(bingo)
			}
		}
		
		//	Four corners…
		
		if (inCard.words[0].marked ?? false)
			&& (inCard.words[kWidth - 1].marked ?? false)
			&& (inCard.words[(kHeight - 1) * kWidth].marked ?? false)
			&& (inCard.words[(kHeight - 1) * kWidth + kWidth - 1].marked ?? false)
		{
			let bingo = Bingo(card: inCard, type: .corners, timestamp: now)
			bingos.append(bingo)
		}
		
		return bingos
	}
	
	/**
		Called by the WebSocket handler to register a callback when a game event occurs.
	*/
	
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
