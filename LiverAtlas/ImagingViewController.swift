//
//  ImagingViewController.swift
//  LiverAtlas
//
//  Created by John on 11/16/16.
//  Copyright © 2016 John Griffin. All rights reserved.
//

import UIKit

class ImagingViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var laImage: LAImage! {
        didSet {
            loadWithImage(imageURL: laImage.imageURL)
        }
    }
    
    func configure(laImage: LAImage) {
        self.laImage = laImage
    }

    var hidesBarOnTapSave: Bool?
    override func viewWillAppear(_ animated: Bool) {
        hidesBarOnTapSave = navigationController?.hidesBarsOnTap
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let _ = hidesBarOnTapSave {
            navigationController?.hidesBarsOnTap = hidesBarOnTapSave!
        }
    }
    
    
    // helpers
    
    private func loadWithImage(imageURL: URL) {
        guard let _ = imageView else {
            return
        }
        
        LACaseFetcher.instance.loadLAImageForURL(imageURL: imageURL) { [weak self] (image, wasCached) in
            assert(Thread.isMainThread)
            guard let _ = image else {
                return
            }
            self?.loadImage(image: image!)
        }
    }
    
    private func loadImage(image: UIImage) {
        let size = image.size
        
        self.imageView.image = image

        scrollView.minimumZoomScale = min(scrollView.bounds.width / size.width, scrollView.bounds.height / size.height)
        scrollView.maximumZoomScale = 6
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = laImage {
            loadWithImage(imageURL: laImage.imageURL)
        }
    }

}

extension ImagingViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContentIntoScrollView()
    }
    
    func centerContentIntoScrollView() {
//        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
//        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
//        contentView.center = CGPoint(x:scrollView.contentSize.width * 0.5 + offsetX,
//                                     y:scrollView.contentSize.height * 0.5 + offsetY)
    }

}
