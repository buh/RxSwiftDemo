//
//  Photo.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum PhotoSize: String {
    static let previewSize = floor(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        / (UIDevice.current.userInterfaceIdiom == .phone ? 3 : 5)) - 5
    
    case preview
    case original
}

struct Photo: Codable {
    
    let thumbURL: URL
    let fullURL: URL
    
    func image(size: PhotoSize) -> Single<UIImage?> {
        let url = size == .preview ? thumbURL : fullURL
        
        return Network.shared.photo(with: url)
            .subscribeOn(SerialDispatchQueueScheduler.init(qos: .background))
            .observeOn(MainScheduler.instance)
    }
}

extension Photo {
    init?(data: [String: Any]) {
        guard let urls = data["urls"] as? [String: String],
            let thumbString = urls["thumb"],
            let fullString = urls["full"],
            let thumbURL = URL(string: thumbString),
            let fullURL = URL(string: fullString) else {
                return nil
        }
        
        self.thumbURL = thumbURL
        self.fullURL = fullURL
    }
}
