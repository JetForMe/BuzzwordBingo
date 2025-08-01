import Vapor










func
routes(_ inApp: Application)
	throws
{
	inApp.get("hello")
	{ _ async -> String in
		"Hello, world!"
	}
}
