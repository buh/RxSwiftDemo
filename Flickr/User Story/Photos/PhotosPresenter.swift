//
//  PhotosPresenter.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol PhotosPresenterProtocol {
    var photos: Driver<[SectionModel<Void, Photo>]> { get }
    func refresh(completion: ((_ error: Error?) -> Void)?)
}

final class PhotosPresenter {
    private let disposeBag = DisposeBag()
    private let photosVariable = Variable<[Photo]>([])
    private let network: NetworkProtocol
    
    private(set) lazy var photos: Driver<[SectionModel<Void, Photo>]> = photosVariable
        .asObservable()
        .map { [SectionModel(model: (), items: $0)] }
        .asDriver(onErrorJustReturn: [])
    
    init(network: NetworkProtocol) {
        self.network = network
        refresh()
    }
}

extension PhotosPresenter: PhotosPresenterProtocol {
    func refresh(completion: ((_ error: Error?) -> Void)? = nil) {
        network.photos()
            .subscribeOn(SerialDispatchQueueScheduler.init(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { photos in
                self.photosVariable.value = photos
                
                if let completion = completion {
                    completion(nil)
                }
            }) { error in
                if let completion = completion {
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }
}
