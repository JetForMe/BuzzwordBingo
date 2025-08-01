import Vapor


import Logging







public
func
configure(_ inApp: Application)
	async
	throws
{
	//	Register static file middleware…
	
	//	This bullshit to find the source Public/ folder, since Xcode can't behave…
	
	let publicDir: String = {
		// This will be something like ".../Sources/App/configure.swift"
		let filePath = #filePath
		let projectRoot = URL(fileURLWithPath: filePath)
			.deletingLastPathComponent() // remove <filename>
			.deletingLastPathComponent() // remove "App"
			.deletingLastPathComponent() // remove "Sources"
			.path

		return projectRoot + "/Public/"
	}()
	
	inApp.middleware.use(FileMiddleware(publicDirectory: publicDir))
	inApp.get
	{ inReq in
		sLogger.info("public dir: \(publicDir)")
		return try await inReq.fileio.asyncStreamFile(at: publicDir + "index.html")
	}
	
	//	Register routs…
	
	try routes(inApp)
}





fileprivate
let
sLogger = Logger(label: "configure.swift")
