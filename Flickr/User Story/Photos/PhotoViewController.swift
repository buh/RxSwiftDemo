//
//  PhotoViewController.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 26/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit
import RxSwift

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    var photo: Photo?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    private func loadPhoto() {
        activityIndicatorView.startAnimating()
        
        photo?.image(size: .original)
            .subscribe(
                onSuccess: { [weak self] in
                    self?.imageView.image = $0
                    self?.activityIndicatorView.stopAnimating()
                },
                onError: { [weak self] error in
                    self?.showAlert(error: error) { self?.loadPhoto() }
                    self?.activityIndicatorView.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
}
