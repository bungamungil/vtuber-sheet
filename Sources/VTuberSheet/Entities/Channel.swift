import Vapor


struct Channel {

    var channelID: String

    var platform: Platform

    var name: String

}


extension Channel: Content { }


extension Channel: Codable { }
