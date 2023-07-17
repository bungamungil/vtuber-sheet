import Vapor


struct VTuber {

    var rowNumber: Int

    var channelID: String

    var platform: Platform

    var name: String

    var persona: String?

    var birthday: Date?

    var affiliation: String?

    var affiliationLogo: String?

}


extension VTuber: Content { }


extension VTuber: Codable { }
