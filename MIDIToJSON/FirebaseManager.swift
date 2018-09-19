//
//  FirebaseManager.swift
//  MIDIToJSON
//
//  Created by Jeff Holtzkener on 2018-09-17.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import UIKit
import Firebase

class FirebaseManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    var filenames = [String]()
    var rootRef: DatabaseReference!
    var fileIndexRef: DatabaseReference!
    var filesRef: DatabaseReference!
    weak var displayDelegate: DisplayDelegate?
    weak var sequencerDelegate: SequencerDelegate?
    
    override init() {
        super.init()
        setupReferences()
        setupObservers()
    }
    
    deinit {
        rootRef.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as UITableViewCell? else { return UITableViewCell() }
        cell.textLabel?.text = filenames[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < filenames.count else { return }
        retrieveFile(filenames[indexPath.row])
        displayDelegate?.reloadLabel(filenames[indexPath.row])
    }
    
    fileprivate func setupReferences() {
        rootRef = Database.database().reference(withPath: "root")
        fileIndexRef = rootRef.child("fileindex")
        filesRef = rootRef.child("files")
    }
    
    // MARK: - Observe Data
    fileprivate func setupObservers() {
        fileIndexRef.observe(.value, with: { snapshot in
            if let val = snapshot.value as? [String] {
                self.filenames = val
                self.displayDelegate?.reloadData()
            }
        })
    }
    
    func retrieveFile(_ name: String) {
        filesRef.child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let fileJSON = snapshot.value as? [String: Any] else { return }
            self.sequencerDelegate?.loadFileFromJSON(fileJSON)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Set Data
    func sendFile(title: String, fileJSON: [String : Any]) {
        filesRef.child(title).setValue(fileJSON)
        filenames.append(title)
        filenames.sort()
        fileIndexRef.setValue(filenames)
        displayDelegate?.reloadLabel(title)
    }
}

protocol DisplayDelegate: class {
    func reloadData()
    func reloadLabel(_ text: String)
}

protocol SequencerDelegate: class {
    func loadFileFromJSON(_ json: [String: Any])
    func getSequencerJSON() -> [String: Any]
}


