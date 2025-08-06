//
//  MapTag.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-05.
//

import LeafKit

struct
MapTag : LeafTag
{
	func
	render(_ inCTX: LeafContext)
		throws
		-> LeafData
	{
		guard
			inCTX.parameters.count == 2
		else
		{
			throw ApplicationError.invalidID("map tag requires two parameters: array and property name")
		}

		guard
			let key = inCTX.parameters[1].string
		else
		{
			throw ApplicationError.invalidID("Second parameter must be a string key")
		}

		guard
			let array = inCTX.parameters[0].array
		else
		{
			throw ApplicationError.invalidID("First parameter must be an array")
		}

		let mapped = array.compactMap { $0.dictionary?[key] }
		return .array(mapped)
	}
}
