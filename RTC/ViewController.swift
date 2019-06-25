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
}

