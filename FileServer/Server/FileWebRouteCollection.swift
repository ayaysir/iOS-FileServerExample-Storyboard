//
//  FileWebRouteCollection.swift
//  FileServer
//
//  Created by yoonbumtae on 2022/08/29.
//

import Vapor

struct FileWebRouteCollection: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: filesViewHandler)
        routes.post(use: uploadFilePostHandler)
        routes.get(":filename", use: downloadFileHandler)
        routes.get("delete", ":filename", use: deleteFileHandler)
    }
    
    func filesViewHandler(_ req: Request) async throws -> View {
        let documentsDirectory = try URL.documentsDirectory()
        let fileUrls = try documentsDirectory.visibleContents()
        let filenames = fileUrls.map { $0.lastPathComponent }
        let context = FileContext(filenames: filenames)
        return try await req.view.render("files", context)
    }
    
    func uploadFilePostHandler(_ req: Request) throws -> Response {
        // 1
        let fileData = try req.content.decode(FileUploadPostData.self)
        
        // 2
        let writeURL = try URL.documentsDirectory().appendingPathComponent(fileData.file.filename)
        
        // 3
        try Data(fileData.file.data.readableBytesView).write(to: writeURL)
        
        // 파일 변경 알림 notification 전송
        notifyFileChange()
        
        // 4
        return req.redirect(to: "/")
    }
    
    func downloadFileHandler(_ req: Request) throws -> Response {
        guard let filename = req.parameters.get("filename") else {
            throw Abort(.badRequest)
        }
        let fileUrl = try URL.documentsDirectory().appendingPathComponent(filename)
        return req.fileio.streamFile(at: fileUrl.path)
    }
    
    func deleteFileHandler(_ req: Request) throws -> Response {
        guard let filename = req.parameters.get("filename") else {
            throw Abort(.badRequest)
        }
        let fileURL = try URL.documentsDirectory().appendingPathComponent(filename)
        try FileManager.default.removeItem(at: fileURL)
        notifyFileChange()
        return req.redirect(to: "/")
    }
    
    func notifyFileChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .serverFilesChanged, object: nil)
        }
    }
}

struct FileContext: Encodable {
    var filenames: [String]
}

struct FileUploadPostData: Content {
    var file: File
}
