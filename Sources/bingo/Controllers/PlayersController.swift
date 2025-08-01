//
//  PlayersController.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//

import Fluent
import Logging
import Vapor






struct
PlayersController : RouteCollection
{
    func
    boot(routes inRoutes: any RoutesBuilder)
    	throws
	{
		inRoutes.get(":nameOrID", use: getPlayer)
		inRoutes.put(":nameOrID", use: loginPlayer)
	}
	
	func
	getPlayer(_ inReq: Request)
		async
		throws
		-> PlayerDTO
	{
		let nameOrID = inReq.parameters.get("nameOrID")!
		
		return try await inReq.db.transaction
		{ inTxn in
			var existingPlayer: Player?
			if let playerID = UUID(uuidString: nameOrID)
			{
				existingPlayer = try await Player
											.query(on: inTxn)
											.filter(\.$id == playerID)
											.first()
			}
			else
			{
				let username = nameOrID.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
				existingPlayer = try await Player
											.query(on: inTxn)
											.filter(\.$username == username)
											.first()
			}
			
			guard
				let existingPlayer
			else
			{
				throw Errors.notFound
			}
			
			let playerDTO = try PlayerDTO(id: existingPlayer.requireID(), name: existingPlayer.name)
			return playerDTO
		}
	}
	
	func
	loginPlayer(_ inReq: Request)
		async
		throws
		-> Response
	{
		let nameOrID = inReq.parameters.get("nameOrID")!
		
		return try await inReq.db.transaction
		{ inTxn in
			var existingPlayer: Player?
			if let playerID = UUID(uuidString: nameOrID)
			{
				existingPlayer = try await Player
											.query(on: inTxn)
											.filter(\.$id == playerID)
											.first()
			}
			else
			{
				existingPlayer = try await Player
											.query(on: inTxn)
											.filter(\.$name == nameOrID)
											.first()
			}
			
			var newPlayer = try inReq.content.decode(PlayerDTO.self)
			
			let player = Player(id: nil, name: newPlayer.name)
			try await player.create(on: inTxn)
			newPlayer = try PlayerDTO(id: player.requireID(), name: player.name)
			
			let resp = Response(status: .created)
			resp.headers.replaceOrAdd(name: .location, value: "/api/players/\(newPlayer.id!.uuidString)")
			try resp.content.encode(newPlayer)
			return resp
		}
	}
}





struct
PlayerDTO : Content
{
	var	id			:	UUID?
	var	name		:	String
}
