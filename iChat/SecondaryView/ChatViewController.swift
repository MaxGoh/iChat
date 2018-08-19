//
//  ChatViewController.swift
//  iChat
//
//  Created by Max Goh on 13/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore


// MARK: Iphone X Layout FIX
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: 1.0).isActive = true
        }
    }
}  // End fix iPhone x

class ChatViewController: JSQMessagesViewController {
     
     var chatRoomId: String!
     var memberIds: [String]!
     var membersToPush: [String]!
     var titleName: String!
     
     let legitTypes = [kAUDIO, kVIDEO, kTEXT, kPICTURE, kLOCATION]
     
     var maxMessageNumber = 0
     var minMessageNumber = 0
     var loadOld = false
     var loadedMessagesCount = 0
     
     
     var messages: [JSQMessage] = []
     var objectMessages: [NSDictionary] = []
     var loadedMessages: [NSDictionary] = []
     var allPictureMessages: [String] = []
     var initialLoadComplete: Bool = false
     
     
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())


    
    // Fix for iPhone X
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    // End of iPhone X fix
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
     
        loadMessages()

        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        // Fix for iPhone X
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint

        constraint.priority = UILayoutPriority(rawValue: 1000)

        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // End of iPhone X fix
        
        // Custom Send Button

        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    // MARK: - JSQMessages Delegate Functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("Camera Pressed")
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("Photo Pressed")
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video Pressed")
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("Location Pressed")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        // For iPad not to crash
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverpresentationcontroller = optionMenu.popoverPresentationController {
                currentPopoverpresentationcontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentationcontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)

            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)

        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            print(text!)
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
            
        } else {
            print("audio message")
        }
    }
    
    // MARK: - Send Messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
          var outgoingMessage: OutgoingMessages?
          let currentUser = FUser.currentUser()!
     
          // Text Message
          if let text = text {
               outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
          }
     
          JSQSystemSoundPlayer.jsq_playMessageSentSound()
          self.finishSendingMessage()
     
          outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
        
    }
     
    // MARK: - Load Messages
    
     func loadMessages() {
          // Get last 11 messages
          reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
               guard let snapshot = snapshot else {
                    self.initialLoadComplete = true
                    // Listen for new chats
                    return
               }
               
               let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
               
               // Remove bad messages
               self.loadedMessages = self.removeBadMessages(allMessages: sorted)
               
               self.insertMessages()
               self.finishReceivingMessage(animated: true)
               
               // Insert Messages
               self.initialLoadComplete = true
               
               print("We have \(self.messages.count) messages loaded")
               
               // Get Picture Messsages
               
               // Get Old Messages in background
               
               // Start listening for new chats
          }
     }
     
     
     // MARK: - Insert Messages
     
     func insertMessages() {
          maxMessageNumber = loadedMessages.count - loadedMessagesCount
          minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
          
          if minMessageNumber < 0 {
               minMessageNumber = 0
          }
          
          for i in minMessageNumber ..< maxMessageNumber {
               let messageDictionary = loadedMessages[i]
               
               insertInitialLoadMessages(messageDictionary: messageDictionary)
               loadedMessagesCount += 1
          }
          
          self.showLoadEarlierMessagesHeader  = (loadedMessagesCount != loadedMessages.count)
     }
     
     func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
          let incomingMessage = IncomingMessages(collectionView_: self.collectionView)
          
          if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
               // Update Message Status
               
          }
          let message = IncomingMessages.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
          
          if message != nil {
               objectMessages.append(messageDictionary)
               messages.append(messageDictionary)
          }
          
          return isIncoming(messageDictionary: messageDictionary )
     }
    
    // MARK: - IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - CustomSendButton
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)

        }
    }
     
     // Mark: - Helper Functions
     
     func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
          var tempMessages = allMessages
          
          for message in tempMessages {
               if message[kTYPE] != nil {
                    if !self.legitTypes.contains(message[kTYPE] as! String) {
                         // Remove the message
                         tempMessages.remove(at: tempMessages.index(of: message)!)
                    }
               } else {
                    tempMessages.remove(at: tempMessages.index(of: message)!)
               }
          }
          
          return tempMessages
     }
     
     func isIncoming(messageDictionary: NSDictionary) -> Bool {
          if FUser.currentId() == messageDictionary[kSENDERID] as! String {
               return false
          } else {
               return true
          }
     }
    

}
