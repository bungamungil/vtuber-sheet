import Foundation
import Redis


struct SpreadsheetValuesResponse {
    
    let values: [[Value]]
    
}


extension SpreadsheetValuesResponse: Codable { }


enum Value {
    
    case int(Int)
    
    case string(String)
    
}


extension Value: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
    
}


extension Value {
    
    var string: String? {
        switch self {
        case .string(let str):
            return str
        default:
            return nil
        }
    }
    
    var int: Int? {
        switch self {
        case .int(let val):
            return val
        default:
            return nil
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .int:
            return false
        case .string(let str):
            return str.isEmpty
        }
    }
    
}
