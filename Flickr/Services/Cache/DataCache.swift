//
//  DataCache.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 27/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import Foundation

final class DataCache: Cache {
    static let shared = DataCache()
    
    init() {
        super.init(name: String(describing: DataCache.self))
    }
    
    func update(key: String, photos: [Photo]) {
        do {
            guard let data = try? JSONEncoder().encode(photos) else {
                return
            }
            
            try data.write(to: filePath(with: key))
        } catch {
            debugPrint(error)
        }
    }
    
    func photos(key: String) -> [Photo]? {
        do {
            let data = try Data(contentsOf: filePath(with: key))
            return try JSONDecoder().decode([Photo].self, from: data)
        } catch {}
        
        return nil
    }
    
    private func filePath(with key: String) -> URL {
        return super.filePath(with: key, extension: "json")
    }
}
