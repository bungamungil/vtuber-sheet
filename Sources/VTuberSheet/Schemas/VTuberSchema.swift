import Graphiti
import Vapor


let vtuberSchema = try! Schema<VTuberResolver, Request>(coders: provideCoders()) {

    Scalar(Date.self)

    Scalar([String].self)

    Enum(Platform.self) {
        Graphiti.Value(.youtube)
        Graphiti.Value(.twitch)
    }

    Type(VTuber.self) {
        Field("channelID", at: \.channelID)
        Field("platform", at: \.platform)
        Field("name", at: \.name)
        Field("persona", at: \.persona)
        Field("birthday", at: \.birthday)
        Field("affiliation", at: \.affiliation)
    }

    ConnectionType(VTuber.self)

    Query {
        Field("vtubers", at: VTuberResolver.getAllVTubers) {
            Argument("first", at: \.first)
            Argument("last", at: \.last)
            Argument("after", at: \.after)
            Argument("before", at: \.before)
        }
    }

}


fileprivate func provideCoders() -> Coders {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM"
    let coders = Coders()
    coders.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    coders.encoder.dateEncodingStrategy = .formatted(dateFormatter)
    return coders
}
