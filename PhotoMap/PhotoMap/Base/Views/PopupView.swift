//
//  PopupView.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/3/21.
//

import UIKit

protocol PopupViewDelegate: AnyObject {
    func changeCategory(completion: @escaping (Category?) -> ())
    func savePhoto(model: PhotoCardModel)
    func showPhoto(with model: PhotoCardModel)
}

class PopupView: UIView {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var annotationImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageBackView: UIView!
    
    weak var delegate: PopupViewDelegate?
    var cardModel: PhotoCardModel?
    
    init(frame: CGRect, model: PhotoCardModel) {
        super.init(frame: frame)
        self.cardModel = model
        setupView(with: model)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cardModel = nil
    }
    
    private func setupView(with model: PhotoCardModel) {
        guard let view = loadFromNib(nibName: "PopupView") else { return }
        view.frame = bounds
        addSubview(view)
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        
        imageBackView.layer.shadowColor = UIColor.black.cgColor
        imageBackView.layer.shadowRadius = 3.0
        imageBackView.layer.shadowOpacity = 0.8
        imageBackView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)

        mainImageView.image = model.image

        dateLabel.text = model.stringDate

        handleCategory(category: model.category)

        textView.layer.cornerRadius = 3.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.text = model.text
        textView.delegate = self
        
        addGestures()
    }
    
    private func addGestures() {
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(changeCategory))
        categoryLabel.addGestureRecognizer(categoryTap)
        
        let mainTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        addGestureRecognizer(mainTap)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(imageTap)
    }
    
    private func handleCategory(category: Category) {
        switch category {
        case .friends:
            annotationImageView.tintColor = .systemOrange
        case .nature:
            annotationImageView.tintColor = .systemGreen
        case .standart:
            annotationImageView.tintColor = .systemBlue
        }
        categoryLabel.text = category.rawValue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animateShow()
    }
    
    private func animateShow() {
        transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.5) {
            self.transform = .identity
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func done(_ sender: Any) {
        guard let cardModel = cardModel else { return }
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            self.delegate?.savePhoto(model: cardModel)
            self.removeFromSuperview()
        }
    }
    
    @objc private func changeCategory() {
        delegate?.changeCategory(completion: { category in
            guard let category = category else { return }
            self.cardModel?.category = category
            self.handleCategory(category: category)
        })
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    @objc private func imageTapped() {
        guard let cardModel = cardModel else { return }
        delegate?.showPhoto(with: cardModel)
    }
}

extension PopupView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        cardModel?.text = text
    }
}
