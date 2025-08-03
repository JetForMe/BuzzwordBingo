import Fluent
import FluentSQLiteDriver
import Logging
import Vapor


import SwiftPath





public
func
configure(_ inApp: Application)
	async
	throws
{
	//	Log some useful stuff…
	
	sLogger.info("Working directory:      \(inApp.directory.workingDirectory)")
	sLogger.info("Path working directory: \(Path.cwd)")
	
	//	Register our Player injection middleware…
	
	inApp.middleware.use(PlayerMiddleware())
	
	//	Register static file middleware…
	
	
	let configuredPublicDir = Environment.get("PUBLIC_DIR")
	sLogger.info("PUBLIC_DIR:             \(String(describing: configuredPublicDir))")
	let publicDir = Path(configuredPublicDir ?? (Path.cwd / "Public").string)!
	sLogger.info("Resolved PUBLIC_DIR:    \(publicDir)")
	
	inApp.middleware.use(FileMiddleware(publicDirectory: publicDir.string))
	inApp.get
	{ inReq in
		sLogger.info("public dir: \(publicDir)")
		let indexPath = publicDir / "index.html"
		return try await inReq.fileio.asyncStreamFile(at: indexPath.string)
	}
	
	//	Configure how we encode dates…
	
	let encoder = JSONEncoder()
	encoder.dateEncodingStrategy = .deferredToDate
	ContentConfiguration.global.use(encoder: encoder, for: .json)
	
	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .deferredToDate
	ContentConfiguration.global.use(decoder: decoder, for: .json)
	
	//	Set up DB…
	
	try await configureDatabase(inApp)
	
	//	Create and store the game engine…
	
	let bingo = BingoEngine(db: inApp.db)
	inApp.storage[BingoKey.self] = bingo
	
	//	Register routes…
	
	try routes(inApp)
}

public
func
configureDatabase(_ inApp: Application)
	async
	throws
{
	if inApp.environment == .testing
	{
		inApp.databases.use(.sqlite(.memory), as: .sqlite)
	}
	else
	{
		let configuredDataDir = Environment.get("DATA_DIR")
		sLogger.info("DATA_DIR:               \(String(describing: configuredDataDir))")
		let dataDir = Path(configuredDataDir ?? (Path.cwd / "data").string)!
		sLogger.info("Resolved DATA_DIR:      \(dataDir)")
		let dbPath = Path(Environment.get("SQLITE_DB_PATH") ?? (dataDir/"db.sqlite").string)!
		sLogger.info("DB path:                \(dbPath)")
		inApp.databases.use(.sqlite(.file(dbPath.string), sqlLogLevel: .debug), as: .sqlite)
		//	TODO: For testing deadlock issues:
//		inApp.databases.use(.postgres(hostname: "localhost", username: "vapor_username", password: "vapor_password", database: "vapor_database"), as: .psql)
	}
	
	//	MARK: Migrations
	//
	//	Note: These need to be done in this order,

	inApp.migrations.add(CreateEnums())
	inApp.migrations.add(CreateGame())
	inApp.migrations.add(CreateGameWord())
	inApp.migrations.add(CreatePlayer())
	inApp.migrations.add(CreatePlayerScore())
	inApp.migrations.add(CreateBingo())
	inApp.migrations.add(CreateCard())
	inApp.migrations.add(CreateCardWord())

//	inApp.migrations.add(UpdateUserV2())
	
	if inApp.environment == .development
		|| inApp.environment == .testing
	{
		inApp.migrations.add(SeedGames())
		inApp.migrations.add(SeedPlayers())
		inApp.migrations.add(SeedCards())
	}
	
	//	Run automigration in dev and testing environments…
	
	if inApp.environment == .development
		|| inApp.environment == .testing
	{
		inApp.logger.info("Running migration")
		try await inApp.autoMigrate()
	}
}


private
struct
BingoKey : StorageKey
{
	typealias Value = BingoEngine
}

extension
Request
{
	var
	bingo: BingoEngine
	{
		self.application.storage[BingoKey.self]!		//	Force-unwrap, because Bingo must be created during app configuration
	}
}

fileprivate
let
sLogger = Logger(label: "configure.swift")


