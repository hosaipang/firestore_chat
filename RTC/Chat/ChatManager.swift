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
    
    func createSingleChatroom(user: User, completionHandler:@escaping (_ roomId: String?) -> Void) {
        createChatroom(users: [user], title: nil, imageUrl: nil, completionHandler: completionHandler)
    }
    
    func createChatroom(users: [User], title: String?, imageUrl: String?, completionHandler:@escaping (_ roomId: String?) -> Void) {
        // Protection from single user
        guard users.count >= 2 else {
            completionHandler(nil)
            return
        }
        
        let db = Firestore.firestore()
        
        var data = [String : Any]()
        data[Constants.keyUsers] = users.map { $0.toDict() }
        
        if let title = title {
            data[Constants.keyTitle] = title
        }
        
        if let imageUrl = imageUrl {
            data[Constants.keyImageUrl] = imageUrl
        }
        
        var roomRef: DocumentReference? = nil
        
        roomRef = db.collection("chatrooms").addDocument(data: data) { error in
            guard error == nil, let roomId = roomRef?.documentID else {
                completionHandler(nil)
                return
            }
            
            completionHandler(roomId)
        }
    }
    
}
