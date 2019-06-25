//
//  ChatManagerConstants.swift
//  RTC
//
//  Created by king on 24/6/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation

extension ChatManager {
    enum Role {
        case admin
        case member
    }
    
    struct User {
        var role: Role
        var userId: String
    }
    
    struct Constants {
        static let keyChatrooms = "chatrooms"
        static let keyUsers = "users"
        static let keyTitle = "title"
        static let keyImageUrl = "image_url"
    }

}
