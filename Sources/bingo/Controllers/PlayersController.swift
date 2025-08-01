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
				existingPlayer = try await Player.find(id: playerID, on: inTxn)
			}
			else
			{
				existingPlayer = try await Player.find(name: nameOrID, on: inTxn)
			}
			
			guard
				let existingPlayer
			else
			{
				throw ApplicationError.notFound("Player \(nameOrID) not found")
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
				existingPlayer = try await Player.find(id: playerID, on: inTxn)
			}
			else
			{
				existingPlayer = try await Player.find(name: nameOrID, on: inTxn)
			}
			
			var playerDTO = try inReq.content.decode(PlayerDTO.self)
			var resp: Response!
			
			if existingPlayer == nil
			{
				existingPlayer = Player(id: nil, name: playerDTO.name)
				try await existingPlayer!.create(on: inTxn)
				
				resp = Response(status: .created)
				resp.headers.replaceOrAdd(name: .location, value: "/api/players/\(try existingPlayer!.requireID().uuidString)")
			}
			else
			{
				existingPlayer!.name = playerDTO.name
				try await existingPlayer!.save(on: inTxn)
				resp = Response(status: .ok)
			}
			
			playerDTO.id = existingPlayer!.id
			playerDTO.name = existingPlayer!.name
			
			try resp.content.encode(playerDTO)
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
