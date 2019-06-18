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

    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rtc = RTCManager();
        rtc.setup()
        
        ref = Database.database().reference(withPath: "chat")
        
        guard let ref = ref else {
            return
        }
        
        let chatroomsRef = ref.child("chatrooms")
        
        let chatroom1Ref = chatroomsRef.child("chatroom1")
        
        let chatroomInfo = ["title" : "chatroom1"]
        
        chatroom1Ref.setValue(chatroomInfo)
        
        ref.observe(.value) { (snapshot) in
            print(snapshot.value as Any)
        }
        
        let db = Firestore.firestore()
        
//        db.collection("users").getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print("Error get: \(err)")
//            } else {
//                for doc in querySnapshot!.documents {
//                    print("\(doc.documentID) => \(doc.data())")
//                }
//            }
//        }
        
        
        
        db.collection("users").document("user1").addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
        }
        
    }

    @IBAction func add() {
        let db = Firestore.firestore()
        var docRef: DocumentReference? = nil
        docRef = db.collection("users").addDocument(data: ["name": "testUser1"]) { err in
            if let err = err {
                print("Add: \(err)")
            } else {
                print("Doc added: \(docRef!.documentID)")
            }
            
        }
    }
    
    @IBAction func add2() {
        let db = Firestore.firestore()
        db.collection("users").document("user1").setData(["name": "user1 name o"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

