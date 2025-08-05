//
//  PlayerMiddleware.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

import Fluent
import Vapor

struct
PlayerMiddleware : AsyncMiddleware
{
	func
	respond(to inReq: Request, chainingTo inNext: any AsyncResponder)
		async
		throws
		-> Response
	{
		guard
			let playerID = inReq.headers.first(name: "Player-ID"),
			let uuid = UUID(uuidString: playerID)
		else
		{
			inReq.storage[PlayerKey.self] = nil
			return try await inNext.respond(to: inReq)
		}

		let player = try await Player.find(id: uuid, on: inReq.db)
		inReq.storage[PlayerKey.self] = player
		return try await inNext.respond(to: inReq)
	}
}

//if let raw = req.cookies["playerID"]?.string, let id = UUID(uuidString: raw) {
//	// Use `id` as the player's ID
//}


private
struct
PlayerKey : StorageKey
{
	typealias Value = Player
}

extension
Request
{
	var
	player: Player?
	{
		self.storage[PlayerKey.self]
	}
	
	func
	requirePlayer()
		throws
		-> Player
	{
		guard
			let player = self.storage[PlayerKey.self]
		else
		{
			throw ApplicationError.playerRequired
		}
		
		return player
	}
}
