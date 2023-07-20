import Vapor

func routes(_ app: Application) throws {

    app.get("vtubers") { req in 
        try await app.vtuberSheet.vtubers
            .paginate(for: req)
            .encode(for: req)
    }

    app.get("affiliations") { req in
        try await app.vtuberSheet.affiliations
            .paginate(for: req)
            .encode(for: req)
    }

    app.get("channels") { req in
        try await app.vtuberSheet.channels
            .paginate(for: req)
            .encode(for: req)
    }

}
