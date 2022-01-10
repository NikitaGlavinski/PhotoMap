//
//  TimeLineCell.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineCellDelegate: AnyObject {
    func loadImage(url: String, completion: @escaping (UIImage) -> ())
}

class TimeLineCell: UITableViewCell {
    
    weak var delegate: TimeLineCellDelegate!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var cellModel: TimeLineCellModel!
    
    func configureCell(with model: TimeLineCellModel) {
        self.cellModel = model
        infoLabel.text = model.infoLabelText
        dateLabel.text = model.secondaryLabelText
        photoImageView.image = nil
        activityIndicator.startAnimating()
        if model.imageUrl != "" {
            delegate.loadImage(url: model.imageUrl) { image in
                self.photoImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = ""
        dateLabel.text = ""
        photoImageView.image = nil
    }
}
