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
		//	Find the playerID either in the header or as a cookie…
		
		var playerID: String? = nil
		if let id = inReq.cookies["playerID"]?.string
		{
			playerID = id
		}
		else if let id = inReq.headers.first(name: "Player-ID")
		{
			playerID = id
		}
		
		//	Load the player…
		
		guard
			let playerID,
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
