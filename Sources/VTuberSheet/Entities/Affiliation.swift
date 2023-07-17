import Vapor


struct Affiliation {

    var name: String

    var logo: String?

}


extension Affiliation: Content { }


extension Affiliation: Codable { }
