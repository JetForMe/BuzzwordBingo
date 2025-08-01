@testable import bingo
import Testing
import VaporTesting







@Suite("Players Tests")
struct
PlayersTests
{
	@Test("Test Get User")
	func
	getUser()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/players/Gregory",
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let returnedPlayer = try inResp.content.decode(PlayerDTO.self)
												#expect(returnedPlayer.id == UUID("035681DF-03EB-44F0-B7D1-4552BD6678AC")!)
												#expect(returnedPlayer.name == "Gregöry")
											})
			try await inApp.testing().test(.GET,
											"/api/players/gregory",
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let returnedPlayer = try inResp.content.decode(PlayerDTO.self)
												#expect(returnedPlayer.id == UUID("035681DF-03EB-44F0-B7D1-4552BD6678AC")!)
												#expect(returnedPlayer.name == "Gregöry")
											})
		}
	}
	
	@Test("Test Register User")
	func
	registerUser()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			let player = PlayerDTO(id: nil, name: "Häifa")
			try await inApp.testing().test(.PUT,
											"/api/players/\(player.name)",
											beforeRequest:
											{ inReq in
												try inReq.content.encode(player)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .created)
												let createdPlayer = try inResp.content.decode(PlayerDTO.self)
												_ = try #require(createdPlayer.id)
												#expect(createdPlayer.name == player.name)
											})
			try await inApp.testing().test(.PUT,
											"/api/players/\(player.name)",
											beforeRequest:
											{ inReq in
												try inReq.content.encode(player)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let createdPlayer = try inResp.content.decode(PlayerDTO.self)
												_ = try #require(createdPlayer.id)
												#expect(createdPlayer.name == player.name)
											})
		}
	}
	
	@Test("Test Register Duplicate User Fails")
	func
	registerDuplicateUser()
		async
		throws
	{
		try await withApp(configure: configure)
		{ inApp in
			let player = PlayerDTO(id: nil, name: "Häifa")
			var id: UUID?
			try await inApp.testing().test(.PUT,
											"/api/players/\(player.name)",
											beforeRequest:
											{ inReq in
												try inReq.content.encode(player)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .created)
												let createdPlayer = try inResp.content.decode(PlayerDTO.self)
												id = try #require(createdPlayer.id)
												#expect(createdPlayer.name == player.name)
											})
			try await inApp.testing().test(.PUT,
											"/api/players/\(player.name)",
											beforeRequest:
											{ inReq in
												try inReq.content.encode(player)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let createdPlayer = try inResp.content.decode(PlayerDTO.self)
												#expect(createdPlayer.id == id)
												#expect(createdPlayer.name == player.name)
											})
		}
	}
}
