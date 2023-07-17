import Graphiti
import Vapor

final class VTuberResolver {
    
    func getAllVTubers(request: Request, arguments: PaginationArguments) async throws -> Connection<VTuber> {
        let vtubers = try await request.application.vtuberSheet.vtubers
        return try vtubers.connection(from: arguments, makeCursor: { 
            Data("\($0.rowNumber)".utf8).bcryptBase64String() 
        })
    }

    func getAllAffiliations(request: Request, arguments: PaginationArguments) async throws -> Connection<Affiliation> {
        let affiliations = try await request.application.vtuberSheet.affiliations
        return try affiliations.connection(from: arguments, makeCursor: { 
            Data($0.name.utf8).bcryptBase64String() 
        })
    }
    
}
