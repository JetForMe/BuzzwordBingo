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
												let games = try inResp.content.decode(GamesDTO.self)
												#expect(games.ownedGames.count == 0)
												#expect(games.playedGames.count == 0)
												#expect(games.otherGames.count == 2)
											})
		}
	}
	
	@Test("Test Get Games With Owner")
	func
	getGamesWithOwner()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games",
											beforeRequest:
											{ ioReq in
												ioReq.headers.add(name: "Player-ID", value: kPlayerIDGregory.uuidString)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let games = try inResp.content.decode(GamesDTO.self)
												#expect(games.ownedGames.count == 2)
												#expect(games.playedGames.count == 1)
												#expect(games.otherGames.count == 0)
											})
		}
	}
	
	@Test("Test Get Games With Player who neither owns nor plays")
	func
	getGamesWithNonOwner()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games",
											beforeRequest:
											{ ioReq in
												ioReq.headers.add(name: "Player-ID", value: kPlayerIDJulia.uuidString)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let games = try inResp.content.decode(GamesDTO.self)
												#expect(games.ownedGames.count == 0)
												#expect(games.playedGames.count == 0)
												#expect(games.otherGames.count == 2)
											})
		}
	}
	
	@Test("Test GET games/shatener2025")
	func
	getGameShatner2025()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games/\(kGameIDShatner2025.uuidString)",
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let game = try inResp.content.decode(GameDTO.self)
												#expect(game.name == "shatner2025")
												#expect(game.displayName == "Shatner 2025")
												#expect(game.words.count == 28)
											})
		}
	}
	
}
