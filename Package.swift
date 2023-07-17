// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "vtuber-sheet",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/alexsteinerde/graphql-kit.git", revision: "4ae5c76"),
        .package(url: "https://github.com/alexsteinerde/graphiql-vapor.git", from: "2.4.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "VTuberSheet",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GraphQLKit", package: "graphql-kit"),
                .product(name: "GraphiQLVapor", package: "graphiql-vapor"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://www.swift.org/server/guides/building.html#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "VTuberSheetTests", dependencies: [
            .target(name: "VTuberSheet"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
