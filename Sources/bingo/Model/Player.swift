//
//  Player.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//

import Foundation

import Fluent












final
class
Player : Model, @unchecked Sendable
{
	static let schema = "Player"
	
	@ID(key: .id)					var id				:	UUID?
	@Field(key: .name)				var name			:	String
	@Field(key: .username)			var username		:	String
	
	init() {}
	
	init(id: UUID? = nil, name: String)
	{
		self.id = id
		self.name = name
		self.username = name.toUsername()
	}
}




extension
Player
{
	static
	func
	find(id inID: UUID, on inDB: any Database)
		async
		throws
		-> Player?
	{
		let result = try await Player
								.query(on: inDB)
								.filter(\.$id == inID)
								.first()
		return result
	}
	
	/**
		Finds the player with the matching ``name``. The match
		is case- and diacritical-insensitive.
	*/
	
	static
	func
	find(name inName: String, on inDB: any Database)
		async
		throws
		-> Player?
	{
		let username = inName.toUsername()
		let result = try await Player
								.query(on: inDB)
								.filter(\.$username == username)
								.first()
		return result
	}
}
