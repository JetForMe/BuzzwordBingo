//
//  SeedDB.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//

import Foundation

import Fluent







let kGameIDShatner2025					=	UUID("6C737A65-5371-4762-94E7-AD59E400803E")!
let kGameIDShatner2024					=	UUID("58F5F6F5-7A0E-4DA2-ABA5-8398758ACE4F")!

let kPlayerIDGregory					=	UUID("035681DF-03EB-44F0-B7D1-4552BD6678AC")!

let kWordIDTrees						=	UUID("39732854-1671-4A05-B290-03081F9A9068")!
let kWordIDHorses						=	UUID("2D2E8DEF-CE96-4B39-918E-87B9689AC76E")!
let kWordIDWhat							=	UUID("08B751C5-2861-4E50-BB9C-7FA94614D24F")!



struct
SeedPlayers : AsyncMigration
{
	/**
		(ID, name)
	*/
	
	let
	defaults: [(UUID, String)] =
	[
		(kPlayerIDGregory, "Gregöry"),
	]
	
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		for (inID, inName) in self.defaults
		{
			let r = Player(id: inID, name: inName)
			try await r.save(on: inDB)
		}
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		for (inID, _) in self.defaults
		{
			try await Player.query(on: inDB).filter(\.$id == inID).delete()
		}
	}
}



struct
SeedGames : AsyncMigration
{
	/**
		Games (ID, ownerID name, Created)
	*/
	
	let
	games: [(UUID, UUID, String, Date)] =
	[
		(kGameIDShatner2025, kPlayerIDGregory, "Shatner 2025", Date()),
		(kGameIDShatner2024, kPlayerIDGregory, "Shatner 2024", Date(timeIntervalSinceNow: -3600.0 * 24 * 365)),
	]
	
	/**
		GameWords (ID, Game ID, Word)
	*/
	
	let
	words: [(UUID, UUID, String)] =
	[
		(kWordIDTrees, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Trees"),
		(kWordIDHorses, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Horses"),
		(kWordIDWhat, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Aliens"),
		(UUID("93355D58-4201-46DC-B2CB-6983D6E1BAA2")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "What?"),
		(UUID("1832FE5A-5C76-461A-BE43-C1780568C6F5")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Intimidation"),
		(UUID("5D252992-AEB4-4CBD-AC9D-44335A94211C")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Set"),
		(UUID("32665FE7-02A4-4FF2-A033-4CC660E300DF")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Blue Origin"),
		(UUID("4552F8B9-F006-431A-8107-3B241CE43174")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Album"),
		(UUID("AAD0C7FE-DC80-4F67-BAD6-40F06A81FF4F")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Sharks"),
		(UUID("DB3FBB25-5AB6-4527-B4C2-5E6DC74FEC0C")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Antarctica"),
		(UUID("799E22BA-3BCB-49B3-8E22-A282C9AF5AC1")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Mortality"),
		(UUID("52046CDB-8E27-4564-8062-F01446D43B25")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "The Universe"),
		(UUID("A4FCBC22-C0CD-427D-8B92-FD854940AB86")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Consciousness"),
		(UUID("8A83172A-AD20-4FDC-BB40-F7166DD44430")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Energy"),
		(UUID("0C7B900C-9037-4773-8420-6959E8C18349")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Ego"),
		(UUID("07BFCCA5-D812-4B31-8B29-E1E2D64EA057")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Time"),
		(UUID("B2F6F151-8C20-494E-A50E-757AAC4C02E9")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Reality"),
		(UUID("9F777272-92F5-47B8-A535-D724BD4DB3BA")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Life and Death"),
		(UUID("05F2E418-E3AB-42C0-BF90-DF05B4A904D2")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Humanity"),
		(UUID("626DD190-7A59-4352-8E30-D5F9F36DC649")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Poetry"),
		(UUID("E6F22E9B-9A9A-49C6-A030-11ADDCA3BFFB")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Motorcycles"),
		(UUID("7035100D-1065-43B0-A4E0-B2414027922B")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Nashville"),
		(UUID("734BF5E4-AD60-4745-9ED3-272C4F8411C5")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Mispronounces Common Word"),
		(UUID("7D8FF186-7192-4EBE-B043-6B416B4C1902")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Talks over Audience"),
		(UUID("EE221BE2-4240-44A1-B781-99DADD50823E")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Twilight Zone"),
		(UUID("A7B11434-8045-4863-A19C-A65FCF9871E4")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Leonard"),
		(UUID("86BBE476-C9C3-4D09-9D02-D1547376DDCA")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Conventions"),
		(UUID("591BB766-C1AD-4E5F-A69D-81291C01FF54")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "“Just Realized”"),
	]
	
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		//	Seed the games…
		
		for (inID, inOwnerID, inName, inCreated) in self.games
		{
			let r = Game(id: inID, ownerID: inOwnerID, displayName: inName, created: inCreated)
			try await r.save(on: inDB)
		}
		
		//	Seed the words…
		
		for (inID, inGameID, inWord) in self.words
		{
			let game = try await Game.query(on: inDB).filter(\.$id == inGameID).first()!
			let r = GameWord(id: inID, game: game, word: inWord)
			try await r.save(on: inDB)
		}
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		//	Deleting games should delete any words associated…
		
		for (inID, _, _, _) in self.games
		{
			try await Game.query(on: inDB).filter(\.$id == inID).delete()
		}
	}
}



struct
SeedCards : AsyncMigration
{
	/**
		(ID, gameID, playerID)
	*/
	
	let
	cards: [(UUID, UUID, UUID)] =
	[
		(UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!, kGameIDShatner2025, kPlayerIDGregory),
	]
	
	/**
		(ID, cardID, wordID, sequence, marked)
	*/
	
	let
	cardsWords: [(UUID, UUID, UUID, Int, Bool)] =
	[
		(UUID("DE62A33D-2C49-4E38-A262-0EA2F48A7F22")!, UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!, kWordIDTrees, 0, false),
		(UUID("C45D4FBA-88C9-43C9-985C-1416C15B6DD5")!, UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!, kWordIDHorses, 1, false),
		(UUID("A42A1A91-AEEC-44BC-8F0E-98BB58A804CA")!, UUID("55E34295-1CFA-4AE8-BC29-C98391779DDD")!, kWordIDWhat, 2, false),
	]
	
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		for (id, gameID, playerID) in self.cards
		{
			let r = Card(id: id, gameID: gameID, playerID: playerID)
			try await r.save(on: inDB)
		}
		for (id, cardID, wordID, sequence, marked) in self.cardsWords
		{
			let r = CardWord(id: id, cardID: cardID, wordID: wordID, sequence: sequence, marked: marked)
			try await r.save(on: inDB)
		}
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		//	CardWords should be deleted by cascade…
		
		for (inID, _, _) in self.cards
		{
			try await Player.query(on: inDB).filter(\.$id == inID).delete()
		}
	}
}

extension
Card
{
	convenience
	init(id: UUID, gameID: UUID, playerID: UUID)
	{
		self.init()
		
		self.id = id
		self.$game.id = gameID
		self.$player.id = playerID
	}
}

extension
CardWord
{
	convenience
	init(id: UUID? = nil, cardID: UUID, wordID: UUID, sequence: Int, marked: Bool? = nil)
	{
		self.init()
		
		self.id = id
		self.$card.id = cardID
		self.$word.id = wordID
		self.sequence = sequence
		self.marked = marked
	}
}
