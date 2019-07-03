//
//  MessageViewController.swift
//  RTC
//
//  Created by king on 2/7/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation
import Firebase

class MessageViewController: UIViewController {
    var chatroomId: String?
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var textField: UITextField?
    
    private var app = UIApplication.shared.delegate as? AppDelegate
    private var messageListener: ListenerRegistration?
    private var previousMessageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private(set) var messages = [Message]()
    
    private var lastCursor: QuerySnapshot?
    private var firstCursor: QuerySnapshot?
    private let pageSize = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousPage()
    }
    
    @IBAction func previousPage() {
        guard let chatroomId = chatroomId else {
            return
        }
        
        if var last = firstCursor?.documents.last {
            
            if let cursorFromLast = lastCursor?.documents.last {
                last = cursorFromLast
            }
            
            previousMessageListener = db.collection(ChatManager.Constants.keyChatrooms)
                .document(chatroomId)
                .collection(ChatManager.Constants.keyMessages)
                .order(by: ChatManager.Constants.keyModifiedDate, descending: true)
                .limit(to: pageSize)
                .start(afterDocument: last)
                .addSnapshotListener({ [weak self] (documentSnapshot, error) in
                    guard let `self` = self else {
                        return
                    }
                    
                    guard error == nil else {
                        self.messages.removeAll()
                        self.tableView?.reloadData()
                        return
                    }
                    
                    self.lastCursor = documentSnapshot
                    
                    documentSnapshot?.documentChanges.forEach({ [weak self] (diff) in
                        guard let `self` = self else {
                            return
                        }
                        
                        let document = diff.document
                        let message = Message(document: document)
                        
                        switch diff.type {
                        case .added:
                            self.messages.append(message)
                            self.messages.sort()
                            
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
                    
                    self.tableView?.reloadData()
                })
            
        } else {
            previousMessageListener = db.collection(ChatManager.Constants.keyChatrooms)
                .document(chatroomId)
                .collection(ChatManager.Constants.keyMessages)
                .order(by: ChatManager.Constants.keyModifiedDate, descending: true)
                .limit(to: pageSize)
                .addSnapshotListener({ [weak self] (documentSnapshot, error) in
                    guard let `self` = self else {
                        return
                    }
                    
                    guard error == nil else {
                        self.messages.removeAll()
                        self.tableView?.reloadData()
                        return
                    }
                    
                    self.firstCursor = documentSnapshot
                    
                    documentSnapshot?.documentChanges.forEach({ [weak self] (diff) in
                        guard let `self` = self else {
                            return
                        }
                        
                        let document = diff.document
                        let message = Message(document: document)
                        
                        switch diff.type {
                        case .added:
                            self.messages.append(message)
                            self.messages.sort()
                            
                            break
                        case .removed:
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
                    
                    self.tableView?.reloadData()
                })
        }
    }
    
    @IBAction func send() {
        guard let textField = textField, let text = textField.text, let roomId = chatroomId, let chatManager = app?.chatManager, let userId = chatManager.uid else {
            return
        }
        
        textField.resignFirstResponder()
        
        chatManager.createMessage(forRoomId: roomId, content: text, senderId: userId) { (messageId) in
            print("messageId=\(String(describing: messageId))")
        }
    }
}

extension MessageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

extension MessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = message.modifiedDate {
            cell.detailTextLabel?.text = formatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
