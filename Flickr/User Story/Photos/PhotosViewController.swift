//
//  PhotosViewController.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxDataSources
import RxGesture

final class PhotosViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.refreshControl = refreshControl
            
            refreshControl.rx.controlEvent(.valueChanged)
                .subscribe(onNext: { [weak self] _ in
                    self?.presenter?.refresh { error in
                        self?.refreshControl.endRefreshing()
                        
                        if let error = error {
                            self?.showAlert(error: error)
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Void, Photo>> = {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void, Photo>>(
            configureCell: { [weak self] (_, collectionView, indexPath, photo) in
                let cell = collectionView.dequeueReusableCell(for: indexPath) as PhotoCollectionCell
                
                // Update the cell image view.
                photo.image(size: .preview)
                    .subscribe(onSuccess: { cell.imageView.image = $0 })
                    .disposed(by: cell.disposeBag)
                
                // Tap or long press on the photo.
                cell.contentView.rx.anyGesture(
                    (.tap(configuration: { _, delegate in delegate.simultaneousRecognitionPolicy = .never }), when: .recognized),
                    (.longPress(configuration: { _, delegate in delegate.simultaneousRecognitionPolicy = .never }), when: .began))
                    .subscribe(onNext: { gesture in
                        if gesture is UITapGestureRecognizer  {
                            self?.performSegue(withIdentifier: String(describing: PhotoViewController.self), sender: photo)
                            
                        } else if let image = cell.imageView.image {
                            self?.share(image: image, fromView: cell)
                        }
                    })
                    .disposed(by: cell.disposeBag)

                return cell
        })
    }()
    
    var presenter: PhotosPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photo = sender as? Photo,
            let photoViewController = segue.destination as? PhotoViewController else {
            return
        }
        
        photoViewController.photo = photo
    }
}

// MARK: Collection View

extension PhotosViewController {
    private func setupCollectionView() {
        guard let presenter = presenter else {
            return
        }
        
        collectionView.register(cellType: PhotoCollectionCell.self)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: PhotoSize.previewSize, height: PhotoSize.previewSize)
        }
        
        presenter.photos.asObservable()
            .do(onNext: { [weak self] sections in
                if let section = sections.first, section.items.count > 0 {
                    self?.activityIndicatorView.stopAnimating()
                }
            })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: Sharing

extension PhotosViewController {
    private func share(image: UIImage, fromView: UIView) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = fromView
        present(activityViewController, animated: true, completion: nil)
    }
}
