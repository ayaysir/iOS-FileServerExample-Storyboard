//
//  FileServer.swift
//  FileServer
//
//  Created by yoonbumtae on 2022/08/29.
//

import Vapor
import Leaf

class FileServer {
    // 1
    var app: Application
    
    var fileURLs: [URL] = []
    
    // 2
    let port: Int
    
    init(port: Int) {
        self.port = port
        
        // 3
        app = Application(.development)
        
        // 4
        configure(app)

    }
    
    private func configure(_ app: Application) {
        // 1
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port
        
        // 2
        app.views.use(.leaf)
        
        // 3
        app.leaf.cache.isEnabled = app.environment.isRelease
        
        // 4
        app.leaf.configuration.rootDirectory = Bundle.main.bundlePath
        
        // 5
        app.routes.defaultMaxBodySize = "50MB"
    }
    
    func start() {
        // 1
        Task(priority: .background) {
            do {
                try app.register(collection: FileWebRouteCollection())
                // 2
                try app.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func loadFiles() {
        do {
            let documentsDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            let fileUrls = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)
            self.fileURLs = fileUrls
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteFile(at offset: Int) {
        // 1
        let urlsToDelete = fileURLs[offset]
        
        // 2
        fileURLs.remove(at: offset)
        
        // 3
        try? FileManager.default.removeItem(at: urlsToDelete)
    }
}

