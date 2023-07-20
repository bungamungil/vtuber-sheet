import ArrayPaginator
import Vapor

extension Array {
    
    func paginate(for req: Request) throws -> Page<Element> {
        let page = try req.query.decode(PageRequest.self)
        return self.paginate(page: page.page, size: page.per)
    }

}


extension Page where T: Codable {
    
    func encode(for req: Request) throws -> Response {
        let response = Response()
        try response.content.encode(self, as: .json)
        return response
    }

}
