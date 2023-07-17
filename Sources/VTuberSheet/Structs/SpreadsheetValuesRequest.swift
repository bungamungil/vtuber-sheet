import Foundation 


struct SpreadsheetValuesRequest {
    
    let dateTimeRenderOption: String
    
    let valueRenderOption: String

    let key: String
    
}


extension SpreadsheetValuesRequest: Codable { }
