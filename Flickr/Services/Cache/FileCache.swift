//
//  FileCache.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 27/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import Foundation
import CryptoSwift

final class FileCache: Cache {
    static let shared = FileCache()
    
    init() {
        super.init(name: String(describing: FileCache.self))
    }
    
    func add(key: String, data: Data) {
        do {
            try data.write(to: filePath(with: key))
        } catch {
            debugPrint(error)
        }
    }
    
    func data(key: String) -> Data? {
        do {
            return try Data(contentsOf: filePath(with: key))
        } catch {
            return nil
        }
    }
    
    private func filePath(with key: String) -> URL {
        return super.filePath(with: key, extension: "jpg")
    }
}
