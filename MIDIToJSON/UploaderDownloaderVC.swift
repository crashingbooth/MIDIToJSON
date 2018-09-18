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
    var firebaseManager: FirebaseManager!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fileDisplayLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager = FirebaseManager()
        tableView.delegate = firebaseManager
        tableView.dataSource = firebaseManager
        firebaseManager.displayDelegate = self
        firebaseManager.sequencerDelegate = customSeq
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
        customSeq.clear()
        fileDisplayLabel.text = "No file loaded"
    }
    
}

extension UploaderDownloaderVC: DisplayDelegate {
    func reloadLabel(_ text: String) {
        fileDisplayLabel.text = "Loaded: \(text)"
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension UploaderDownloaderVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        customSeq.loadFromURL(urls[0])
        navigationController?.popViewController(animated: true)
        
        let json = customSeq.getSequencerJSON()
        let name = urls[0].lastPathComponent.filter { $0 != "."}
        fileDisplayLabel.text = "Loaded: \(name)"
        firebaseManager.sendFile(title: name, fileJSON: json)
    }
}


