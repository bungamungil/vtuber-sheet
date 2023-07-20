import Vapor

func routes(_ app: Application) throws {

    app.get("vtubers") { req in 
        return try await app.vtuberSheet.vtubers
            .paginate(for: req)
            .encode(for: req)
    }

    app.get("affiliations") { req in
        return try await app.vtuberSheet.affiliations
            .paginate(for: req)
            .encode(for: req)
    }

}
