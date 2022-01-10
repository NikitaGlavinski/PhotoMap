//
//  TableViewModels.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import Foundation

struct TimeLineSection {
    var title: String
    var rows: [TimeLineCellModel]
    
    init(title: String, rows: [TimeLineCellModel]) {
        self.title = title
        self.rows = rows
    }
}

struct TimeLineCellModel {
    var id: String
    var imageUrl: String
    var infoLabelText: String
    var date: Double
    var secondaryLabelText: String
    var sectionTitle: String
    var category: String
    
    init(id: String, imageUrl: String, text: String, date: Double, stringDate: String, sectionTitle: String, category: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.infoLabelText = text
        self.date = date
        self.secondaryLabelText = stringDate
        self.sectionTitle = sectionTitle
        self.category = category
    }
    
    init(photoRestModel: PhotoRestModel) {
        self.id = photoRestModel.id
        self.imageUrl = photoRestModel.imageUrl
        self.infoLabelText = photoRestModel.text
        self.date = photoRestModel.date
        let date = Date(timeIntervalSince1970: photoRestModel.date)
        self.secondaryLabelText = CustomDateFormatter.shared.string(from: date, format: "MM-dd-yy") + " / \(photoRestModel.category)"
        self.sectionTitle = CustomDateFormatter.shared.string(from: date, format: "MMMM yyyy")
        self.category = photoRestModel.category
    }
}
