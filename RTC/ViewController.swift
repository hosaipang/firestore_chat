//
//  ViewController.swift
//  RTC
//
//  Created by king on 29/4/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var app = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}

