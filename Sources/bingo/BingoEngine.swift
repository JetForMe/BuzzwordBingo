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
		
		//	If unmarking, check for lost Bingos…
		
		if !inMark
		{
			let lostBingos = card.findLostBingos(at: inSequence)
//			sdfg
		}
		
		//	Mark the word…
		
		let cw = card.words[inSequence]
		cw.marked = inMark
		Self.logger.info("Marked card: \(inMark)")
		
		try await cw.save(on: inDB)
		
		//	Whether marking or unmarking, add Bingos…
		
//		var newBingos = false		//	TODO: Do we need this?
		let bingos = try card.findBingos()
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
		
		Task
		{
			let gameID = card.$game.id
			if let clients = self.clients[gameID]
			{
				//	TODO: task group!
				for (_, handler) in clients
				{
					try? await handler(gameID, inCardID, inSequence, inMark, playerScore!)
				}
			}
		}
		return cw
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



extension
Card
{
	subscript(_ inIdx: Int)
		-> CardWord
	{
		return self.words[inIdx]
	}
	
	subscript(col inCol: Int, row inRow: Int)
		-> CardWord
	{
		let idx = inRow * kWidth + inCol
		return self.words[idx]
	}
	
	enum
	Corner
	{
		case ul
		case ur
		case ll
		case lr
	}
	
	subscript(corner inCorner: Corner)
		-> CardWord
	{
		switch (inCorner)
		{
			case .ul:		return self.words[0]
			case .ur:		return self[col: kWidth - 1, row: 0]
			case .ll:		return self[col: 0, row: kHeight - 1]
			case .lr:		return self[col: kWidth - 1, row: kHeight - 1]
		}
	}
	
	func
	index(forCol: Int, row: Int)
		-> Int
	{
		let idx = row * kWidth + forCol
		return idx
	}
	
	func
	colRow(forIndex inIdx: Int)
		-> (Int, Int)
	{
		let col = inIdx % kWidth
		let row = inIdx / kWidth
		return (col, row)
	}
	
	func
	index(forCorner inCorner: Corner)
		-> Int
	{
		switch (inCorner)
		{
			case .ul:		return index(forCol: 0, row: 0)
			case .ur:		return index(forCol:kWidth - 1, row: 0)
			case .ll:		return index(forCol:0, row: kHeight - 1)
			case .lr:		return index(forCol:kWidth - 1, row: kHeight - 1)
		}
	}

	/**
	*/
	
	func
	findLostBingos(at inIdx: Int)
		-> [Bingo]
	{
		//	Test each possible bingo including the word at inIdx,
		//	and remove them…
		
		let (col, row) = colRow(forIndex: inIdx)
		
		var	bingos = [Bingo]()
		
		//	If inIdx is one of the four corners…
		
		let idxUL = self.index(forCorner: .ul)
		let idxUR = self.index(forCorner: .ur)
		let idxLL = self.index(forCorner: .ll)
		let idxLR = self.index(forCorner: .lr)
		if ([idxUL, idxUR, idxLL, idxLR].contains(inIdx))
		{
			//	If the card had the four corners marked, remove it…
			
			if (self.words[idxUL].marked ?? false)
				&& (self.words[idxUR].marked ?? false)
				&& (self.words[idxLL].marked ?? false)
				&& (self.words[idxLR].marked ?? false)
			{
				let bingo = Bingo(card: self, type: .corners, timestamp: Date())		//	Note: actual date is arbitrary, as this is used to search for a Bingo in the DB, ignoring the timestamp.
				bingos.append(bingo)
			}
		}
		
		//	Diagonals…
		
		if (col == row)					//	UL to LR
		{
		}
		
		if (kWidth - col - 1 == row)	//	UR to LL
		{
		}
		
		
		//	Rows…
		
		//	Columns…
		
		return bingos
	}
	
	/**
		Find all bingos in the Card. The returned
		Bingos are not written to the DB, and will
		need to be deduped by the caller.
	*/
	
	func
	findBingos()
		throws
		-> [Bingo]
	{
		let now = Date()
		
		var bingos = [Bingo]()
		
		//	Search each row…
		
		for row in 0 ..< self.kHeight
		{
			if hasBingo(row: row)
			{
				let bingo = Bingo(card: self, type: .row, index: row, timestamp: now)
				bingos.append(bingo)
			}
		}
		
		//	Search each column…
		
		for col in 0 ..< self.kWidth
		{
			if hasBingo(col: col)
			{
				let bingo = Bingo(card: self, type: .column, index: col, timestamp: now)
				bingos.append(bingo)
			}
		}
		
		//	Diagonals…
		
		if hasBingoDiagonalULLR()
		{
			let bingo = Bingo(card: self, type: .ulbr, timestamp: now)
			bingos.append(bingo)
		}
		
		if hasBingoDiagonalURLL()
		{
			let bingo = Bingo(card: self, type: .llur, timestamp: now)
			bingos.append(bingo)
		}
		
		//	Four corners…
		
		if hasBingoFourCorners()
		{
			let bingo = Bingo(card: self, type: .corners, timestamp: now)
			bingos.append(bingo)
		}
		
		return bingos
	}
	
	func
	hasBingo(row: Int)
		-> Bool
	{
		var isBingo = true
		for col in 0 ..< self.kWidth
		{
			if !(self[col: col, row: row].marked ?? false)
			{
				isBingo = false
				break
			}
		}
		return isBingo
	}
	
	func
	hasBingo(col: Int)
		-> Bool
	{
		var isBingo = true
		for row in 0 ..< self.kHeight
		{
			if !(self[col: col, row: row].marked ?? false)
			{
				isBingo = false
				break
			}
		}
		
		return isBingo
	}
	
	func
	hasBingoDiagonalULLR()
		-> Bool
	{
		guard self.kWidth == self.kHeight else { return false }
		
		var isBingo = true
		for d in 0 ..< self.kWidth
		{
			if !(self[col: d, row: d].marked ?? false)
			{
				isBingo = false
				break
			}
		}
		
		return isBingo
	}
	
	func
	hasBingoDiagonalURLL()
		-> Bool
	{
		guard self.kWidth == self.kHeight else { return false }
		
		var isBingo = true
		for d in 0 ..< self.kWidth
		{
			if !(self[col: self.kWidth - d - 1, row: d].marked ?? false)
			{
				isBingo = false
				break
			}
		}
		
		return isBingo
	}
	
	func
	hasBingoFourCorners()
		-> Bool
	{
		return     (self[corner: .ul].marked ?? false)
				&& (self[corner: .ur].marked ?? false)
				&& (self[corner: .ll].marked ?? false)
				&& (self[corner: .lr].marked ?? false)
	}
}
