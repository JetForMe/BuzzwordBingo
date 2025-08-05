//
//  JoinTag.swift
//  bingo
//
//  Created by Rick Mann on 2025-08-05.
//


import LeafKit

struct
JoinTag : LeafTag
{
	func
	render(_ inCTX: LeafContext)
		throws
		-> LeafData
	{
		guard
			inCTX.parameters.count == 2
			|| inCTX.parameters.count == 3
		else
		{
			throw ApplicationError.invalidID("#join requires two or three parameters")
		}
		
		guard
			let separator = inCTX.parameters[1].string
		else
		{
			throw ApplicationError.invalidID("#join requires the second parameter to be a string")
		}
		
		guard
			let inputArray = inCTX.parameters[0].array
		else
		{
			throw ApplicationError.invalidID("#join requires the first parameter to be an array")
		}
		
		var strings: [String]
		if let propertyName = inCTX.parameters[2].string
		{
			strings = inputArray.compactMap { $0.dictionary?[propertyName]?.string }
		}
		else
		{
			strings = inputArray.compactMap { $0.string }
		}
		
		let result = strings.joined(separator: separator)
		return .string(result)
	}
}
