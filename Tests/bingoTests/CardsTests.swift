//
//  CardsTests.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

@testable import bingo
import Testing
import VaporTesting




@Suite("Players Tests")
struct
CardsTests
{
	@Test("Test Get Player Card")
	func
	getPlayerCard()
		async
		throws
	{
		let playerID = kPlayerIDGregory
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/games/Shatner2025/card",
											beforeRequest:
											{ ioReq in
												ioReq.headers.add(name: "Player-ID", value: playerID.uuidString)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let card = try inResp.content.decode(CardDTO.self)
												#expect(card.gameID == UUID("6C737A65-5371-4762-94E7-AD59E400803E")!)
												#expect(card.playerID == playerID)
												#expect(card.words.count == 25)
												
												//	Ensure they’re sorted by sequence…
												
												var lastSequence = -1
												var words = Set<String>()
												for cw in card.words
												{
													#expect(lastSequence < cw.sequence)
													lastSequence = cw.sequence
													
													words.insert(cw.word)
												}
												
												//	Ensure there are no duplicates…
												
												#expect(words.count == card.words.count)
											})
		}
	}
	
	@Test("Test /cards/:id")
	func
	getCardByID()
		async
		throws
	{
		let cardID = UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/cards/\(cardID.uuidString)",
											beforeRequest:
											{ ioReq in
//												ioReq.headers.add(name: "Player-ID", value: playerID.uuidString)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let card = try inResp.content.decode(CardDTO.self)
												#expect(card.gameID == kGameIDShatner2025)
												#expect(card.playerID == kPlayerIDGregory)
												#expect(card.words.count == 3)
												
												//	Ensure they’re sorted by sequence…
												
												var lastSequence = -1
												var words = Set<String>()
												for cw in card.words
												{
													#expect(lastSequence < cw.sequence)
													lastSequence = cw.sequence
													
													words.insert(cw.word)
												}
												
												//	Ensure there are no duplicates…
												
												#expect(words.count == card.words.count)
											})
		}
	}
	
	@Test("Test GET /cards/:id/words/:sequence")
	func
	getCardWord()
		async
		throws
	{
		let cardID = UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!
		try await withApp(configure: configure)
		{ inApp in
			try await inApp.testing().test(.GET,
											"/api/cards/\(cardID.uuidString)/words/1",
											beforeRequest:
											{ ioReq in
//												ioReq.headers.add(name: "Player-ID", value: playerID.uuidString)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let cardWord = try inResp.content.decode(CardWordDTO.self)
												#expect(cardWord.word == "Horses")
												#expect(cardWord.sequence == 1)
												#expect(cardWord.marked == false)
											})
		}
	}
	
#if false
	@Test("Test PUT /cards/:id/words/:sequence")
	func
	markCardWord()
		async
		throws
	{
		let cardID = UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!
		
		try await withApp(configure: configure)
		{ inApp in
			//	TODO: Add websocket client connection
			try await inApp.testing().test(.PUT,
											"/api/cards/\(cardID.uuidString)/words/1",
											beforeRequest:
											{ ioReq in
												ioReq.headers.add(name: "Player-ID", value: kPlayerIDGregory.uuidString)
												
												let op = UpdateCardWordOp(setMarked: true)
												try ioReq.content.encode(op)
											},
											afterResponse:
											{ inResp async throws in
												#expect(inResp.status == .ok)
												let result = try inResp.content.decode(UpdateCardWordOpResult.self)
												#expect(result.status == "OK")
												#expect(result.cardWord.id == UUID("C45D4FBA-88C9-43C9-985C-1416C15B6DD5")!)
												#expect(result.cardWord.word == "Horses")
												try #expect(#require(result.cardWord.marked))
											})
		}
	}
#endif
}
