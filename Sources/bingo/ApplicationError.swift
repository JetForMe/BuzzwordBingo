//
//  Errors.swift
//  bingo
//
//  Created by Rick Mann on 2025-07-31.
//


import Vapor


protocol AppError: AbortError, DebuggableError {}



enum
ApplicationError : AppError
{
	case gameHasNoWords
	case invalidID(String)
	case notAuthorized
	case notFound(String?)
	case playerRequired
}


extension
ApplicationError : AbortError
{
	var
	status: HTTPResponseStatus
	{
		switch self
		{
			case .gameHasNoWords:					return .unprocessableEntity
			case .invalidID:						return .badRequest
			case .notAuthorized:					return .unauthorized
			case .notFound:							return .notFound
			case .playerRequired:					return .badRequest
		}
	}
	
    var
    reason: String
    {
        switch self
        {
        	case .gameHasNoWords:					return "Game has no words from which to generate a Card"
			case .invalidID(let s):					return "Invalid ID \"\(s)\""
			case .notFound(nil):					return "Not Found"
			case .notAuthorized:					return "Player not authorized"
			case .notFound(let msg?):				return "\(msg)"
			case .playerRequired:					return "A Player is required in this request"
		}
	}

    var
    identifier: String
    {
        switch self
        {
			case .gameHasNoWords:					return "gameHasNoWords"
			case .invalidID:						return "invalidID"
			case .notAuthorized:					return "notAuthorized"
			case .notFound:							return "notFound"
			case .playerRequired:					return "playerRequired"
		}
	}
}

