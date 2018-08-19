//
//  OutgoingMessages.swift
//  iChat
//
//  Created by Max Goh on 15/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import Foundation


class OutgoingMessages {
    let messageDictionary: NSMutableDictionary
    
    // MARK: - Initializers
    
    // text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // MARK: - Send Message
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
            
        }
        
        // Update Recent Chat
        
        // Send Push Notification
    }
}
