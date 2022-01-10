//
//  PhotoScreenViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import UIKit

protocol PhotoScreenViewInput: AnyObject {
    func setupUI(with model: PhotoCardModel)
    func showError(error: Error)
}

class PhotoScreenViewController: UIViewController {
    
    var viewModel: PhotoScreenViewModelProtocol!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    
    private lazy var zoomTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomingTap))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    
    private lazy var hideTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideViews))
        return tap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        setupGestures()
    }
    
    private func setupGestures() {
        zoomTap.delegate = self
        hideTap.delegate = self
        imageView.addGestureRecognizer(zoomTap)
        imageView.addGestureRecognizer(hideTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)
    }
    
    private func zoom(point: CGPoint, animated: Bool) {
        let currectScale = scrollView.zoomScale
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        
        if minScale == maxScale && minScale > 1 {
            return
        }
        let toScale = maxScale
        let finalScale = currectScale == minScale ? toScale : minScale
        let zoomRect = zoomRect(scale: finalScale, center: point)
        scrollView.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = scrollView.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    private func handleImagePanHide() {
        UIView.animate(withDuration: 0.2) {
            if self.imageView.center.y < self.scrollView.center.y {
                self.imageView.frame.origin.y = -self.imageView.frame.height
            } else {
                self.imageView.frame.origin.y = self.imageView.frame.height
            }
        } completion: { _ in
            self.viewModel.goBack(animated: false)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        viewModel.goBack(animated: true)
    }
    
    @objc private func zoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoom(point: location, animated: true)
    }
    
    @objc private func hideViews() {
        if topView.alpha != 0.0 {
            UIView.animate(withDuration: 0.2) {
                self.topView.alpha = 0.0
                self.backButton.alpha = 0.0
                self.bottomView.alpha = 0.0
                self.containerView.alpha = 0.0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.topView.alpha = 0.5
                self.backButton.alpha = 1.0
                self.bottomView.alpha = 0.5
                self.containerView.alpha = 1.0
            }
        }
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        switch sender.state {
        case .changed:
            imageView.center.y += translation.y
            sender.setTranslation(.zero, in: view)
        case .ended:
            if abs(imageView.center.y - scrollView.center.y) > 250 {
                handleImagePanHide()
            } else if sender.velocity(in: view).y >= 1400 || sender.velocity(in: view).y <= -1400 {
                handleImagePanHide()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.imageView.center = self.scrollView.center
                }
            }
        default:
            break
        }
    }
}

extension PhotoScreenViewController: PhotoScreenViewInput {
    
    func setupUI(with model: PhotoCardModel) {
        textLabel.text = model.text
        dateLabel.text = model.stringDate
        userLabel.text = model.email
        if let image = model.image {
            imageView.image = image
        } else {
            viewModel.loadImage(url: model.imageUrl ?? "") { image in
                self.imageView.image = image
            }
        }
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    private var scrollViewVisibleSize: CGSize {
        let contentInset = scrollView.contentInset
        let scrollViewSize = scrollView.bounds.standardized.size
        let width = scrollViewSize.width - contentInset.left - contentInset.right
        let height = scrollViewSize.height - contentInset.top - contentInset.bottom
        return CGSize(width:width, height:height)
    }
    
    private var scrollViewCenter: CGPoint {
        let scrollViewSize = self.scrollViewVisibleSize
        return CGPoint(x: scrollViewSize.width / 2.0,
                       y: scrollViewSize.height / 2.0)
    }
    
    private func centerScrollViewContents() {
        
        let scrollViewSize = scrollViewVisibleSize

        var imageCenter = CGPoint(x: scrollView.contentSize.width / 2.0,
                                  y: scrollView.contentSize.height / 2.0)

        let center = scrollViewCenter

        if scrollView.contentSize.width < scrollViewSize.width {
            imageCenter.x = center.x
        }

        if scrollView.contentSize.height < scrollViewSize.height {
            imageCenter.y = center.y
        }

        imageView.center = imageCenter
    }
}

extension PhotoScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == zoomTap {
            return true
        }
        if otherGestureRecognizer == scrollView.panGestureRecognizer && scrollView.zoomScale > 1.0 {
            return true
        }
        return false
    }
}
