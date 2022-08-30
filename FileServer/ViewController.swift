//
//  ViewController.swift
//  FileServer
//
//  Created by yoonbumtae on 2022/08/29.
//

import UIKit
import QuickLook

class ViewController: UIViewController {
    
    @IBOutlet weak var tbvFileList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var server = FileServer(port: 8080)
    
    var previewURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbvFileList.delegate = self
        tbvFileList.dataSource = self
        
        server.start()
        server.loadFiles()
        // lblTitle.text = ProcessInfo().hostName + ":\(server.port)"
        lblTitle.text = getIPAddress() + ":\(server.port)"
        print(server.fileURLs)
        
        
        NotificationCenter.default.addObserver(forName: .serverFilesChanged, object: nil, queue: .main) { _ in
            print("Observer: ServerFilesChanged")
            self.server.loadFiles()
            self.tbvFileList.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            server.deleteFile(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        server.fileURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FileNameCell") else {
            fatalError("CELL IS NOT EXIST")
        }
        
        if let label = cell.contentView.subviews[0] as? UILabel {
            label.text = "\(server.fileURLs[indexPath.row].lastPathComponent)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        previewURL = server.fileURLs[indexPath.row]
        
        let previewVC = QLPreviewController()
        previewVC.delegate = self
        previewVC.dataSource = self
        
        self.present(previewVC, animated: true)
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        previewURL as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .disabled
    }
}
