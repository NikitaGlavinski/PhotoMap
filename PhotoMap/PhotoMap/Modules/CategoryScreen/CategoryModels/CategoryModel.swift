//
//  CategoryCellModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import UIKit

struct CategoryModel: Codable {
    var title: String
    var isSelected: Bool
    
    init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case isSelected = "isSelected"
    }
}
