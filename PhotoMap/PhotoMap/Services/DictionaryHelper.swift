//
//  DictionaryHelper.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/6/21.
//

import Foundation

class DictionaryEncoder {
    
    private let encoder = JSONEncoder()
    
    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let data = try encoder.encode(value)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
}

class DictionaryDecoder {
    
    private let decoder = JSONDecoder()
    
    func decode<T>(data: [String: Any], type: T.Type) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: data, options: [])
        return try decoder.decode(type, from: data)
    }
}
