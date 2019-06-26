//
//  ChatManager.swift
//  RTC
//
//  Created by king on 24/6/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation
import Firebase

class ChatManager {
    
    private let db = Firestore.firestore()
    
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
        data[Constants.keyUsers] = users.map { $0.toDict() }
        
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
    
}
