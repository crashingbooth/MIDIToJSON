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
    weak var tableViewReloadDelegate: TableViewReloadDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    fileprivate func setupReferences() {
        rootRef = Database.database().reference(withPath: "root")
        fileIndexRef = rootRef.child("fileindex")
        filesRef = rootRef.child("files")
    }
    
    fileprivate func setupObservers() {
        fileIndexRef.observe(.value, with: { snapshot in
            if let val = snapshot.value as? [String] {
                self.filenames = val
                self.tableViewReloadDelegate?.reloadData()
            }
            
        })
    }
    
}

protocol TableViewReloadDelegate: class {
    func reloadData()
}
