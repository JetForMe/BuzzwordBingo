// swift-tools-version:6.0

import PackageDescription





let
package = Package(
	name: "bingo",
	platforms:
	[
		.macOS(.v13),
	],
	dependencies:
	[
		.package(url: "https://github.com/apple/swift-nio.git",				from:	"2.65.0"),
		
	    .package(url: "https://github.com/JetForMe/SwiftPath",				branch: "rmann/sendable"),
		
		.package(url: "https://github.com/vapor/fluent.git",				from:	"4.12.0"),
		.package(url: "https://github.com/vapor/fluent-sqlite-driver.git",	from:	"4.8.1"),
		.package(url: "https://github.com/vapor/vapor.git",					from:	"4.115.0"),
	],
	targets:
	[
		.executableTarget(
			name: "bingo",
			dependencies:
			[
				.product(name: "Fluent",								package: "fluent"),
				.product(name: "FluentSQLiteDriver",					package: "fluent-sqlite-driver"),
				.product(name: "NIOCore",								package: "swift-nio"),
				.product(name: "NIOPosix",								package: "swift-nio"),
				.product(name: "SwiftPath", 							package: "SwiftPath"),
				.product(name: "Vapor",									package: "vapor"),
			],
			resources:
			[
				.copy("../../Public")
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "bingoTests",
			dependencies:
			[
				.target(name: "bingo"),
				.product(name: "VaporTesting",							package: "vapor"),
			],
			swiftSettings: swiftSettings
		),
	]
)

var swiftSettings: [SwiftSetting]
{ [
	.enableUpcomingFeature("ExistentialAny"),
] }
