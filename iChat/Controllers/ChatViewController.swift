//
//  ChatViewController.swift
//  iChat
//
//  Created by Max Goh on 10/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVC, animated: true)
        
    }
    
}
