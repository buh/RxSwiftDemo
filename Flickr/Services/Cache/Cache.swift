//
//  Cache.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 27/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import Foundation

class Cache {
    let cacheURL: URL
    
    init(name: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        cacheURL = URL(fileURLWithPath: documentsPath).appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            try! FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
            cacheURL.excludeFromBackup()
        }
    }
    
    func filePath(with key: String, extension: String) -> URL {
        return cacheURL.appendingPathComponent(key.md5().lowercased()).appendingPathExtension(`extension`)
    }
}

// MARK: Extensions for URL

extension URL {
    fileprivate func excludeFromBackup() {
        var url = self
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? url.setResourceValues(resourceValues)
    }
}
