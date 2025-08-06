//
//  ViewsController.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-05.
//

import Fluent
import Leaf
import Logging
import Vapor






struct
ViewsController : RouteCollection
{
    func
    boot(routes inRoutes: any RoutesBuilder)
    	throws
	{
		inRoutes.get(use: getHome)
		inRoutes.get("games", use: getGames)
		inRoutes.get("games", ":nameOrID", use: getGame)
	}
	
	func
	getHome(_ inReq: Request)
		async
		throws
		-> View
	{
		let games = try await GamesController().getGames(inReq)
		let leafContext = LeafTemplateContext(currentPlayer: inReq.player, games: games)
		return try await inReq.view.render("index", leafContext)
	}
	
	func
	getGames(_ inReq: Request)
		async
		throws
		-> View
	{
		let games = try await GamesController().getGames(inReq)
		let leafContext = LeafTemplateContext(currentPlayer: inReq.player, games: games)
		return try await inReq.view.render("games", leafContext)
	}
	
	func
	getGame(_ inReq: Request)
		async
		throws
		-> View
	{
		let nameOrID = inReq.parameters.get("nameOrID")!
		
		guard
			let dbGame = try await Game.find(nameOrID: nameOrID, on: inReq.db)
		else
		{
			throw ApplicationError.notFound("Game \(nameOrID) not found")
		}
		
		let game = try GameDTO(game: dbGame)
		let card = try await GamesController().getPlayerCard(inReq)
		
		let leafContext = LeafTemplateContext(currentPlayer: inReq.player, currentGame: game, currentCard: card)
		return try await inReq.view.render("game", leafContext)
	}
}
