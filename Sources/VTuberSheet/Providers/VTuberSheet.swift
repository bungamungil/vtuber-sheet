import Redis
import Vapor


extension Application {

    struct VTuberSheet {
        
        fileprivate let application: Application

        final class Storage {
            let spreadsheetID: String
            let range: String

            init(spreadsheetID: String, range: String) {
                self.spreadsheetID = spreadsheetID
                self.range = range
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        static let VTuberRedisKey: RedisKey = "VtuberSheet:VTubers"

        static let AffiliationRedisKey: RedisKey = "VtuberSheet:Affiliations"

        fileprivate var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }

        fileprivate func initialize() {
            self.application.storage[Key.self] = .init(spreadsheetID: "", range: "")
        }

        func use(spreadsheetID: String, range: String) {
            self.application.storage[Key.self] = .init(spreadsheetID: spreadsheetID, range: range)
        }

        var spreadsheetID: String {
            self.storage.spreadsheetID
        }

        var range: String {
            self.storage.range
        }

        var baseURL: String {
            "https://sheets.googleapis.com/v4/spreadsheets/\(self.spreadsheetID)/values/\(self.range)"
        }

        var vtubers: [VTuber] {
            get async throws {
                if let vtubers = try await self.application.redis.get(Self.VTuberRedisKey, asJSON: [VTuber].self) {
                    self.application.logger.info("Using cached response")
                    return vtubers
                }
                let vtubers: [VTuber] = try await self.values
                    .enumerated()
                    .flatMap(self.parseVTuber)
                try await self.application.redis.setex(Self.VTuberRedisKey, toJSON: vtubers, expirationInSeconds: self.application.cacheSettings.expirationInSeconds)
                return vtubers
            }
        }

        var affiliations: [Affiliation] {
            get async throws {
                if let affiliations = try await self.application.redis.get(Self.AffiliationRedisKey, asJSON: [Affiliation].self) {
                    self.application.logger.info("Using cached response")
                    return affiliations
                }
                let affiliations: [Affiliation] = try await self.values
                    .enumerated()
                    .flatMap(self.parseAffiliation)
                    .filter(self.filter)
                    .uniqued(on: self.uniqued)
                try await self.application.redis.setex(Self.AffiliationRedisKey, toJSON: affiliations, expirationInSeconds: self.application.cacheSettings.expirationInSeconds)
                return affiliations
            }
        }

        fileprivate func filter(row: [Value]) -> Bool {
            if row.isGraduated {
                return false
            }
            if row.isTerminated {
                return false
            }
            return row.channelID != nil
        }

        fileprivate func filter(affiliation: Affiliation) -> Bool {
            if affiliation.name == "-" {
                return false
            }
            return true
        }

        fileprivate func uniqued(on affiliation: Affiliation) -> String {
            return affiliation.name
        }

        fileprivate func parseVTuber(index: Int, row: [Value]) -> [VTuber] {
            guard let vtuberModel = row.asVTuber(on: index + 1) else {
                return []
            }
            return [vtuberModel]
        }

        fileprivate func parseAffiliation(index: Int, row: [Value]) -> [Affiliation] {
            guard let affiliationModel = row.asAffiliation() else {
                return []
            }
            return [affiliationModel]
        }

        private var values: [[Value]] {
            get async throws {
                let request = try await self.application.client.get(URI(string: baseURL)) { req in
                    try req.query.encode(SpreadsheetValuesRequest(
                        dateTimeRenderOption: "FORMATTED_STRING", 
                        valueRenderOption: "FORMULA", 
                        key: self.application.googleAPI.key
                    ))
                }
                let values = try request.content.decode(SpreadsheetValuesResponse.self).values.filter(self.filter)
                self.application.logger.info("Using remote response")
                return values
            }
        }
        
    }

    var vtuberSheet: VTuberSheet {
        .init(application: self)
    }

}


extension Array where Element == Value {
    
    fileprivate func asVTuber(on rowNumber: Int) -> VTuber? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        if self.count > 2 && !self[0].isEmpty, let channelID = self[0].string?.components(separatedBy: "\"").dropLast().last, let vtuberName = self[1].string {
            if !channelID.hasPrefix("UC") {
                return nil
            }
            var vtuber = VTuber(rowNumber: rowNumber, channelID: channelID, platform: .youtube, name: vtuberName)
            if self.count > 8 && !self[7].isEmpty { // Row H
                vtuber.persona = self[7].string
            }
            if self.count > 12 && !self[11].isEmpty, let dateStr = self[11].string { // Row L
                vtuber.birthday = formatter.date(from: dateStr)
            }
            if self.count > 13 && !self[12].isEmpty { // Row M
                vtuber.affiliation = self[12].string
            }
            if self.count > 14 && !self[13].isEmpty { // Row N
                vtuber.affiliationLogo = self[13].string?.components(separatedBy: "\"").dropLast().last
            }
            return vtuber
        }
        return nil
    }

    fileprivate func asAffiliation() -> Affiliation? {
        if self.count > 13 && !self[12].isEmpty, let name = self[12].string {
            var affiliation = Affiliation(name: name)
            if self.count > 14 && !self[13].isEmpty {
                affiliation.logo = self[13].string?.components(separatedBy: "\"").dropLast().last
            }
            return affiliation
        }
        return nil
    }
    
    fileprivate var isGraduated: Bool {
        return self.count > 13 && self[12].string == "GRADUATED"
    }

    fileprivate var isTerminated: Bool {
        return self.count > 13 && self[12].string == "TERMINATED"
    }

    fileprivate var channelID: String? {
        if self.count > 2 && !self[0].isEmpty, let channelID = self[0].string?.components(separatedBy: "\"").dropLast().last {
            if !channelID.hasPrefix("UC") {
                return nil
            }
            return channelID
        }
        return nil
    }
    
}
