import Vapor


struct VTuber {

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


extension VTuber {

    init(from channel: Channel) {
        self.channelID = channel.channelID
        self.platform = channel.platform
        self.name = channel.name
    }

}