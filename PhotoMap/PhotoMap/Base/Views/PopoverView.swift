//
//  PopoverView.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import UIKit

protocol PopoverViewDelegate: AnyObject {
    func loadImageFrom(url: String, completion: @escaping (UIImage) -> ())
    func openPopup(model: PhotoCardModel)
}

class PopoverView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backimageView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private weak var delegate: PopoverViewDelegate?
    private var photoModel: PhotoCardModel?
    
    init(frame: CGRect, model: PhotoCardModel, delegate: PopoverViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.photoModel = model
        setupView(with: model)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let photoModel = photoModel else { return }
        for view in subviews {
            view.removeFromSuperview()
        }
        setupView(with: photoModel)
    }
    
    func setupView(with model: PhotoCardModel) {
        guard let view = loadFromNib(nibName: "PopoverView") else { return }
        view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 35)
        view.backgroundColor = .clear
        addSubview(view)
        backgroundColor = .clear
        
        backimageView.layer.shadowColor = UIColor.black.cgColor
        backimageView.layer.shadowRadius = 3.0
        backimageView.layer.shadowOpacity = 0.8
        backimageView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        backimageView.layer.masksToBounds = false
        
        textLabel.text = model.text
        emailLabel.text = model.email
        
        let date = Date(timeIntervalSince1970: model.date)
        dateLabel.text = CustomDateFormatter.shared.string(from: date, format: "MM-dd-yyyy")
        
        if let image = model.image {
            imageView.image = image
        } else {
            activityIndicator.startAnimating()
            delegate?.loadImageFrom(url: model.imageUrl ?? "", completion: { image in
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
                self.photoModel?.image = image
            })
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        view.addGestureRecognizer(tap)
        addGestureRecognizer(tap)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let size = self.bounds
        let p1 = CGPoint(x: size.origin.x, y: size.origin.y + 15)
        let p2 = CGPoint(x: size.origin.x + 15, y: size.origin.y)
        let control1 = size.origin
        let p3 = CGPoint(x: size.width - 15, y: p2.y)
        let p4 = CGPoint(x: size.width, y: p1.y)
        let control2 = CGPoint(x: size.width, y: size.origin.y)
        let p5 = CGPoint(x: p4.x, y: size.height - 35 - 15)
        let p6 = CGPoint(x: p5.x - 15, y: size.height - 35)
        let control3 = CGPoint(x: p5.x, y: p6.y)
        let p7 = CGPoint(x: size.width / 2 + 25, y: p6.y)
        let p8 = CGPoint(x: p7.x - 10, y: p7.y + 8)
        let control4 = CGPoint(x: p8.x + 5 , y: p7.y)
        let p9 = CGPoint(x: size.width / 2 - 15, y: p8.y)
        let control5 = CGPoint(x: size.width / 2, y: size.height + 10)
        let p10 = CGPoint(x: size.width / 2 - 25, y: size.height - 35)
        let control6 = CGPoint(x: size.width / 2 - 25 + 10 - 5, y: p10.y)
        let p11 = CGPoint(x: size.origin.x + 15, y: size.height - 35)
        let p12 = CGPoint(x: size.origin.x, y: p11.y - 15)
        let control7 = CGPoint(x: p12.x, y: p11.y)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addQuadCurve(to: p2, controlPoint: control1)
        path.addLine(to: p3)
        path.addQuadCurve(to: p4, controlPoint: control2)
        path.addLine(to: p5)
        path.addQuadCurve(to: p6, controlPoint: control3)
        path.addLine(to: p7)
        path.addQuadCurve(to: p8, controlPoint: control4)
        path.addQuadCurve(to: p9, controlPoint: control5)
        path.addQuadCurve(to: p10, controlPoint: control6)
        path.addLine(to: p11)
        path.addQuadCurve(to: p12, controlPoint: control7)
        path.close()
        
        UIColor.white.set()
        path.fill()
    }
    
    @objc private func openPopup() {
        guard let photoModel = photoModel else { return }
        delegate?.openPopup(model: photoModel)
    }
}
