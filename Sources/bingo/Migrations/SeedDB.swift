//
//  SeedDB.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//

import Foundation

import Fluent











struct
SeedGames : AsyncMigration
{
	/**
		(ID, name, Created)
	*/
	
	let
	defaults: [(UUID, String, Date)] =
	[
		(UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "Shatner2025", Date()),
		(UUID("58F5F6F5-7A0E-4DA2-ABA5-8398758ACE4F")!, "Shatner2024", Date(timeIntervalSinceNow: -3600.0 * 24 * 365)),
	]
	
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		for (inID, inName, inCreated) in self.defaults
		{
			let r = Game(id: inID, name: inName, created: inCreated)
			try await r.save(on: inDB)
		}
	}

	func
	revert(on inDB: any Database)
		async
		throws
	{
		for (inID, _, _) in self.defaults
		{
			try await Game.query(on: inDB).filter(\.$id == inID).delete()
		}
	}
}




struct
SeedGameWords : AsyncMigration
{
	/**
		(ID, name, Created)
	*/
	
	let
	defaults: [(UUID, UUID, String)] =
	[
		(UUID("39732854-1671-4A05-B290-03081F9A9068")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "trees"),
		(UUID("2D2E8DEF-CE96-4B39-918E-87B9689AC76E")!, UUID("6C737A65-5371-4762-94E7-AD59E400803E")!, "horses"),
	]
	
	func
	prepare(on inDB: any Database)
		async
		throws
	{
		for (inID, inGameID, inWord) in self.defaults
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
		for (inID, _, _) in self.defaults
		{
			try await GameWord.query(on: inDB).filter(\.$id == inID).delete()
		}
	}
}

struct
SeedPlayers : AsyncMigration
{
	/**
		(ID, name)
	*/
	
	let
	defaults: [(UUID, String)] =
	[
		(UUID("035681DF-03EB-44F0-B7D1-4552BD6678AC")!, "Gregöry"),
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

