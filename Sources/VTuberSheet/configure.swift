import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    
    guard let googleAPIKey = Environment.get("GOOGLE_API_KEY") else {
        fatalError("Google API key not found")
    }
    app.googleAPI.use(key: googleAPIKey)
    
    guard let spreadsheetID = Environment.get("SPREADSHEET_ID") else {
        fatalError("Spreadsheet ID not found")
    }
    guard let range = Environment.get("CELL_RANGE") else {
        fatalError("Cell range not found")
    }
    app.vtuberSheet.use(spreadsheetID: spreadsheetID, range: range)

    app.middleware.use(app.sessions.middleware)

    let redisConfiguration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "", 
        port: Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? 6379, 
        password: Environment.get("REDIS_PASSWORD")
    )

    app.queues.use(.redis(redisConfiguration))
    app.redis.configuration = redisConfiguration

    if let expirationInSeconds = Environment.get("CACHE_EXPIRATION_IN_SECONDS").flatMap(Int.init(_:)) {
        app.cacheSettings.set(expirationInSeconds: expirationInSeconds)
    }
    
    try routes(app)
}
