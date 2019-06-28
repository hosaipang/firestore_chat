//
//  ChatManager.swift
//  RTC
//
//  Created by king on 24/6/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation
import Firebase

protocol ChatManagerDelegate: NSObject {
    func chatroomDidChange()
}

class ChatManager {
    weak var delegate: ChatManagerDelegate?
    
    private let db = Firestore.firestore()
    private var chatroomListener: ListenerRegistration?
    
    private(set) var chatrooms = [Chatroom]()
    private(set) var uid: String?
    
    init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        db.settings = settings
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.updateUser(uid: user?.uid)
            
            if user?.uid != nil {
                self?.addChatroomListener()
            }
        }
    }
    
    func signIn(mid: String) {
        let link = "http://192.168.1.146:3000?mid=\(mid)"
        guard let url = URL(string: link) else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            guard let str = String(data: data, encoding: String.Encoding.utf8) else {
                return
            }
            
            Auth.auth().signIn(withCustomToken: str) { (user, error) in
                guard error == nil, let user = user else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                print("user=\(user)")
            }
        }
        task.resume()
    }
    
    func signOut() throws {
        updateOnlineStatus(isOnline: false)
        try Auth.auth().signOut()
    }
    
    func updateUser(uid: String?) {
        self.uid = uid
        
        if let uid = uid {
            updateOnlineStatus(uid: uid, isOnline: true)
        }
    }
    
    func updateOnlineStatus(uid: String, isOnline: Bool) {
        let userData = [Constants.keyOnline : isOnline]
        
        db.collection(Constants.keyUsers).document(uid).setData(userData) { err in
            
        }
    }
    
    func updateOnlineStatus(isOnline: Bool) {
        guard let myUid = uid else { return }
        
        updateOnlineStatus(uid: myUid, isOnline: isOnline)
    }
    
    func createSingleChatroom(user: User, completionHandler:@escaping (_ roomId: String?) -> Void) {
        createChatroom(users: [user], title: nil, imageUrl: nil, completionHandler: completionHandler)
    }
    
    func createChatroom(users: [User], title: String?, imageUrl: String?, completionHandler:@escaping (_ roomId: String?) -> Void) {
        // Protection from single user
        guard users.count >= 2 else {
            completionHandler(nil)
            return
        }
        
        var data = [String : Any]()
        
        var usersDict = [String : Any]()
        for user in users {
            usersDict[user.userId] = user.role.rawValue
        }
        
        data[Constants.keyRoles] = usersDict
        
        if let title = title {
            data[Constants.keyTitle] = title
        }
        
        if let imageUrl = imageUrl {
            data[Constants.keyImageUrl] = imageUrl
        }
        
        data[Constants.keyModifiedDate] = Date()
        
        var roomRef: DocumentReference? = nil
        
        roomRef = db.collection(Constants.keyChatrooms).addDocument(data: data) { error in
            guard error == nil, let roomId = roomRef?.documentID else {
                completionHandler(nil)
                return
            }
            
            completionHandler(roomId)
        }
    }
    
    func createMessage(forRoomId roomId: String, content: String, senderId: String, completionHandler:@escaping (_ messageId: String?) -> Void) {
        var data = [String : Any]()
        data[Constants.keyContent] = content
        data[Constants.keySenderId] = senderId
        
        data[Constants.keyModifiedDate] = Date()
        
        var messageRef: DocumentReference? = nil
        messageRef = db.collection(Constants.keyChatrooms).document(roomId).collection(Constants.keyMessages).addDocument(data: data, completion: { (error) in
            guard error == nil, let messageId = messageRef?.documentID else {
                completionHandler(nil)
                return
            }
            
            completionHandler(messageId)
        })
    }
    
    func queryAllChatrooms(completionHandler:@escaping (_ rooms: [QueryDocumentSnapshot]?) -> Void) {
        let _ = db.collection(Constants.keyChatrooms)
            .order(by: Constants.keyModifiedDate, descending: true)
            .getDocuments { (querySnapshot, err) in
            guard err == nil, let querySnapshot = querySnapshot else {
                completionHandler(nil)
                return
            }
            
            completionHandler(querySnapshot.documents)
        }
    }
    
    private func addChatroomListener() {
        guard uid != nil else {
            return
        }
        
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
                        guard let index = self?.chatrooms.firstIndex(of: chatroom) else {
                            return
                        }
                        
                        self?.chatrooms.remove(at: index)
                        break
                    case .modified:
                        guard let index = self?.chatrooms.firstIndex(of: chatroom) else {
                            return
                        }
                        
                        self?.chatrooms[index] = chatroom
                        break
                    default:
                        break
                    }
                })
                
                self?.delegate?.chatroomDidChange()
        }
    }
    
}
