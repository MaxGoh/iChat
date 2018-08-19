//
//  ProfileViewTableViewController.swift
//  iChat
//
//  Created by Max Goh on 11/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - IBActions
    @IBAction func callButtonPressed(_ sender: Any) {
        print("call user \(user!.fullname)")
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        print("chat user \(user!.fullname)")
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        
        if  currentBlockedIds.contains(user!.objectId) {
            currentBlockedIds.remove(at: currentBlockedIds.index(of: user!.objectId)!)
        } else {
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error updating user \(error)")
                return
            }
            self.updateBlockStatus()
        }
        
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)

        }
        
    }

    
}
