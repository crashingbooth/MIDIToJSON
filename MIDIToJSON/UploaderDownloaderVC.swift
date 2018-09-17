//
//  UploaderDownloaderVC.swift
//  MIDIToJSON
//
//  Created by Jeff Holtzkener on 2018-09-17.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import UIKit

class UploaderDownloaderVC: UIViewController {
    var customSeq = CustomSequencer()
    let firebaseManager = FirebaseManager()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = firebaseManager
        tableView.dataSource = firebaseManager
        firebaseManager.tableViewReloadDelegate = self
    }

    @IBAction func getFileFromICloud(_ sender: Any) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.midi-audio"], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func play(_ sender: Any) {
        customSeq.play()
    }
    @IBAction func stop(_ sender: Any) {
        customSeq.stop()
    }
    @IBAction func clear(_ sender: Any) {
    }
    
}

extension UploaderDownloaderVC: TableViewReloadDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}

extension UploaderDownloaderVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        customSeq.loadFromURL(urls[0])
        navigationController?.popViewController(animated: true)
        
        let json = customSeq.seq.jsonifyTracks()
        let name = urls[0].lastPathComponent.filter { $0 != "."}
        firebaseManager.sendFile(title: name, fileJSON: json)
    }
}


