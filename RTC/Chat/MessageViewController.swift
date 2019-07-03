//
//  MessageViewController.swift
//  RTC
//
//  Created by king on 2/7/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation
import Firebase

class MessageViewController: UITableViewController {
    var chatroomId: String?
    
    private var messageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private(set) var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chatroomId = chatroomId else {
            return
        }
        
        messageListener = db.collection(ChatManager.Constants.keyChatrooms)
        .document(chatroomId)
        .collection(ChatManager.Constants.keyMessages)
        .order(by: ChatManager.Constants.keyModifiedDate, descending: false)
            .addSnapshotListener({ [weak self] (documentSnapshot, error) in
                guard let `self` = self else {
                    return
                }
                
                guard error == nil else {
                    self.messages.removeAll()
                    self.tableView.reloadData()
                    return
                }
                
                documentSnapshot?.documentChanges.forEach({ [weak self] (diff) in
                    guard let `self` = self else {
                        return
                    }
                    
                    let document = diff.document
                    let message = Message(document: document)
                    
                    switch diff.type {
                    case .added:
                        self.messages.append(message)
                        break
                    case .removed:
                        guard let index = self.messages.firstIndex(of: message) else {
                            return
                        }
                        
                        self.messages.remove(at: index)
                        break
                    case .modified:
                        guard let index = self.messages.firstIndex(of: message) else {
                            return
                        }
                        
                        self.messages[index] = message
                        break
                    default:
                        break
                    }
                })
                
                self.tableView.reloadData()
            })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.content
        
        return cell
    }
}
