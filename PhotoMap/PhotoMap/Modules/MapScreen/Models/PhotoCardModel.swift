//
//  PhotoCardModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/3/21.
//

import Foundation
import UIKit

enum Category: String {
    case friends = "FRIENDS"
    case nature = "NATURE"
    case standart = "DEFAULT"
}

struct PhotoCardModel {
    var id: String
    var image: UIImage?
    var imageUrl: String?
    var date: Double
    var stringDate: String
    var category: Category
    var text: String
    var lat: Double
    var lon: Double
    var email: String
    
    init(
        image: UIImage,
        date: Double,
        stringDate: String,
        category: Category,
        text: String,
        lat: Double,
        lon: Double,
        email: String
    ) {
        self.id = UUID().uuidString
        self.image = image
        self.date = date
        let convertDate = Date(timeIntervalSince1970: date)
        self.stringDate = CustomDateFormatter.shared.string(from: convertDate, format: "MMMM d'th,' yyyy '-' HH:mm a")
        self.category = category
        self.text = text
        self.lat = lat
        self.lon = lon
        self.email = email
    }
    
    init(restModel: PhotoRestModel) {
        self.id = restModel.id
        self.imageUrl = restModel.imageUrl
        self.date = restModel.date
        self.stringDate = restModel.stringDate
        self.text = restModel.text
        self.lat = restModel.lat
        self.lon = restModel.lon
        self.email = restModel.email
        switch restModel.category {
        case "FRIENDS":
            self.category = .friends
        case "NATURE":
            self.category = .nature
        case "DEFAULT":
            self.category = .standart
        default:
            self.category = .friends
        }
    }
}

struct PhotoRestModel: Codable {
    var id: String
    var imageUrl: String
    var date: Double
    var stringDate: String
    var category: String
    var text: String
    var lat: Double
    var lon: Double
    var email: String
    
    init(cardModel: PhotoCardModel, imageUrl: String) {
        self.id = cardModel.id
        self.imageUrl = imageUrl
        self.date = cardModel.date
        self.stringDate = cardModel.stringDate
        self.category = cardModel.category.rawValue
        self.text = cardModel.text
        self.lat = cardModel.lat
        self.lon = cardModel.lon
        self.email = cardModel.email
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case imageUrl = "imageUrl"
        case date = "date"
        case stringDate = "stringDate"
        case category = "category"
        case text = "text"
        case lat = "lat"
        case lon = "lon"
        case email = "email"
    }
}
