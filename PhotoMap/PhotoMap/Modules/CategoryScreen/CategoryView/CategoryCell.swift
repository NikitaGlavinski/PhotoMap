//
//  CategoryCell.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configureCell(with model: CategoryModel) {
        titleLabel.text = model.title
        selectionView.layer.borderWidth = 1.0
        selectionView.layer.cornerRadius = 20.0
        switch model.title {
        case "FRIENDS":
            titleLabel.textColor = .systemOrange
            selectionView.layer.borderColor = UIColor.systemOrange.cgColor
        case "NATURE":
            titleLabel.textColor = .systemGreen
            selectionView.layer.borderColor = UIColor.systemGreen.cgColor
        case "DEFAULT":
            titleLabel.textColor = .systemBlue
            selectionView.layer.borderColor = UIColor.systemBlue.cgColor
        default:
            break
        }
        changeSelection(model: model)
    }
    
    func changeSelection(model: CategoryModel) {
        switch model.title {
        case "FRIENDS":
            selectionView.backgroundColor = model.isSelected ? UIColor.systemOrange : .clear
        case "NATURE":
            selectionView.backgroundColor = model.isSelected ? UIColor.systemGreen : .clear
        case "DEFAULT":
            selectionView.backgroundColor = model.isSelected ? UIColor.systemBlue : .clear
        default:
            break
        }
        selectionView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.selectionView.transform = .identity
        }
    }
}
