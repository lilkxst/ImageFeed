//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Артём Костянко on 16.05.23.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageScrollView(image: image)
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    var singleImageURL: String = ""
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        downloadLargeImage()
    }
    
    private func rescaleAndCenterImageScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func downloadLargeImage() {
        guard let imageURL = URL(string: singleImageURL) else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let result):
                self.rescaleAndCenterImageScrollView(image: result.image)
            case .failure:
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Попробовать еще раз?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .default) { [weak self] result in
            self?.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] result in
            self?.downloadLargeImage()
        })
        
        present(alert, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
