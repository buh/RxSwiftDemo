//
//  Network.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit
import RxSwift

protocol NetworkProtocol {
    func photos() -> Single<[Photo]>
    func photo(with url: URL) -> Single<UIImage?>
}

final class Network {
    private let config: URLSessionConfiguration = {
        var config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Client-ID 4354eca257552d39210292df64388c6e01d949e159b9d0410df6cd8a9b5fab81"]
        return config
    }()
    
    private lazy var session = URLSession(configuration: config)
    
    static let shared = Network()
}

extension Network: NetworkProtocol {
    func photos() -> Single<[Photo]> {
        return Single<[Photo]>.create(subscribe: { [weak self] single -> Disposable in
            guard let `self` = self,
                let url = URL(string: "https://api.unsplash.com/photos?per_page=60") else {
                return Disposables.create()
            }
            
            let cacheKey = url.absoluteString
            
            if let photos = DataCache.shared.photos(key: cacheKey) {
                single(.success(photos))
            }
            
            let task = self.session.dataTask(with: url) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data else {
                    single(.success([]))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    if let photosData = json as? [[String: Any]] {
                        let photos = photosData
                            .map { photoData -> Photo? in Photo(data: photoData) }
                            .compactMap { $0 }
                        
                        DataCache.shared.update(key: cacheKey, photos: photos)
                        single(.success(photos))
                    } else {
                        single(.success([]))
                    }
                } catch {
                    single(.error(error))
                }
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        })
    }
    
    func photo(with url: URL) -> Single<UIImage?> {
        return Single<UIImage?>.create(subscribe: { [weak self] single -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let cacheKey = url.absoluteString
            
            if let data = FileCache.shared.data(key: cacheKey) {
                single(.success(UIImage(data: data)))
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: url) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                if let data = data {
                    FileCache.shared.add(key: cacheKey, data: data)
                    single(.success(UIImage(data: data)))
                } else {
                    single(.success(nil))
                }
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        })
    }
}
