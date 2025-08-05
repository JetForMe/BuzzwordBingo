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
		inRoutes.get("me", use: getCurrentPlayer)
		inRoutes.get(":nameOrID", use: getPlayer)
		inRoutes.put(":nameOrID", use: loginPlayer)
	}
	
	func
	getCurrentPlayer(_ inReq: Request)
		async
		throws
		-> PlayerDTO
	{
		return try await inReq.db.transaction
		{ inTxn in
			let player = try inReq.requirePlayer()
			
			let games = try await Game.find(forPlayerID: player.requireID(), on: inTxn)
			let gamesDTO = try games.map { try GameDTO(game: $0) }
			let playerDTO = try PlayerDTO(id: player.requireID(), name: player.name, games: gamesDTO)
			return playerDTO
		}
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
			
			//	Set the PlayerID cookie:
			
			resp.cookies["playerID"] = HTTPCookies
										.Value(string: existingPlayer!.id!.uuidString,
												expires: Date().addingTimeInterval(60 * 60 * 24 * 30),		// 30 days
												path: "/",
												isHTTPOnly: false,											// allow JavaScript access if needed
												sameSite: .lax)												// or .none for cross-site
			
			//	Encode the player DTO…
			
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
	var	games		:	[GameDTO]?
}
