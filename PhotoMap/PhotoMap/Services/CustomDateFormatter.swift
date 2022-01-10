//
//  CustomDateFormatter.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/13/21.
//

import Foundation

protocol CustomDateFormatterProtocol: AnyObject {
    func string(from date: Date, format: String) -> String
}

class CustomDateFormatter: CustomDateFormatterProtocol {
    
    static let shared: CustomDateFormatterProtocol = CustomDateFormatter()
    private init() {}
    
    private var formatter = DateFormatter()
    
    func string(from date: Date, format: String) -> String {
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
