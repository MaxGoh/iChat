//
//  IncomingMessages.swift
//  iChat
//
//  Created by Max Goh on 18/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    // MARK: - CreateMessage
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            // Create Message
            createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            // Create Picture Message
            print("Picture Message")

        case kVIDEO:
            // Create Video  Message
            print("Video Message")

        case kAUDIO:
            // Create Audio Message
            print("Audio Message")

        case kLOCATION:
            // Create Location Message
            print("Location Message")

        default:
            print("Unknown Message Type")
            break
        }
        
        if message != nil {
            return message
        }
        
        return nil
    }
    
    // MARK: - Create Message Types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as! String
        let userId = messageDictionary[kUSERID] as! String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
}
