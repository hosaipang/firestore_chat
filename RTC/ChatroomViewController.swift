//
//  ChatroomViewController.swift
//  RTC
//
//  Created by king on 29/4/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import UIKit
import Firebase

class ChatroomViewController: UIViewController {

    @IBOutlet var tableView: UITableView?
    
    private let chatroomCellIdentifier = "chatroomCell"
    
    private var app = UIApplication.shared.delegate as? AppDelegate
    
    private var chatroomListener: ListenerRegistration?
    
    private var chatrooms = [Chatroom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChatroomListener()
    }
    
    private func addChatroomListener() {
        let db = Firestore.firestore()
        chatroomListener = db.collection(ChatManager.Constants.keyChatrooms)
            .order(by: ChatManager.Constants.keyModifiedDate, descending: true)
            .addSnapshotListener { [weak self] (documentSnapshot, error) in
                documentSnapshot?.documentChanges.forEach({ [weak self] (diff) in
                    let document = diff.document
                    let chatroom = Chatroom(document: document)
                    
                    switch diff.type {
                    case .added:
                        self?.chatrooms.append(chatroom)
                        self?.chatrooms.sort()
                        break
                    case .removed:
                        guard let index = self?.chatrooms.firstIndex(of: chatroom) else { return }
                        self?.chatrooms.remove(at: index)
                        break
                    case .modified:
                        guard let index = self?.chatrooms.firstIndex(of: chatroom) else { return }
                        self?.chatrooms[index] = chatroom
                        break
                    default:
                        break
                    }
                })
                
                self?.tableView?.reloadData()
        }
    }
    
    @IBAction func createChatRoom() {
        let userAdmin = ChatManager.User(userId: "1", role: ChatManager.Role.admin)
        let userMember = ChatManager.User(userId: "2", role: ChatManager.Role.member)
        app?.chatManager?.createChatroom(users: [userAdmin, userMember], title: "test room", imageUrl: "image.jpg", completionHandler: { (roomId) in
            print(roomId ?? "createChatRoom error")
        })
    }
    
    @IBAction func createChatRoomAndSendMessage() {
        let userAdmin = ChatManager.User(userId: "1", role: ChatManager.Role.admin)
        let userMember = ChatManager.User(userId: "2", role: ChatManager.Role.member)
        app?.chatManager?.createChatroom(users: [userAdmin, userMember], title: "test room", imageUrl: "image.jpg", completionHandler: { [weak self] (roomId) in
            print(roomId ?? "createChatRoom error")
            
            if let roomId = roomId {
                self?.app?.chatManager?.createMessage(forRoomId: roomId, content: "test message content", senderId: "1", completionHandler: { (messageId) in
                    print(messageId ?? "create message error")
                })
            }
        })
    }
    
    @IBAction func queryChatRooms() {
        app?.chatManager?.queryAllChatrooms(completionHandler: { (rooms) in
            guard let rooms = rooms else {
                return
            }
            
            for document in rooms {
                print("\(document.documentID) => \(document.data())")
            }
        })
    }
    
    @IBAction func signIn() {
        let alert = UIAlertController(title: "Sign in by Mid", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak self] (_) in
            guard let textField = alert?.textFields?.first, let mid = textField.text, mid.count > 0 else { return }
            self?.app?.chatManager?.signIn(mid: mid)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signOut() {
        do {
            try app?.chatManager?.signOut()
            chatrooms.removeAll()
            tableView?.reloadData()
        } catch {
            print("sign out error=\(error)")
        }
    }
}

extension ChatroomViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: chatroomCellIdentifier, for: indexPath) as? ChatroomCell else {
            return UITableViewCell()
        }
        
        let chatroom = chatrooms[indexPath.row]
        cell.titleLabel.text = chatroom.id
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = chatroom.modifiedDate {
            cell.timeLabel.text = formatter.string(from: date)
        } else {
            cell.timeLabel.text = ""
        }
        
        return cell
    }

}
