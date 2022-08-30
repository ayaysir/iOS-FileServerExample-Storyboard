//
//  URL+.swift
//  FileServer
//
//  Created by yoonbumtae on 2022/08/29.
//

import Foundation

extension URL {
    static func documentsDirectory() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
    }
    
    func visibleContents() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles)
    }
}

