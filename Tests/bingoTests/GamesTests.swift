//
//  GamesTests.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

@testable import bingo
import Testing
import VaporTesting




@Suite("Players Tests")
struct
GamesTests
{
	@Test("Test Get Games")
	func
	getGames()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games",
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let games = try inResp.content.decode([GameDTO].self)
												#expect(games.count == 2)
											})
		}
	}
	
	@Test("Test GET games/Shatener2025")
	func
	getGameShatner2025()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games/Shatner2025",
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let game = try inResp.content.decode(GameDTO.self)
												#expect(game.name == "Shatner2025")
											})
		}
	}
	
}
