//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by Max Goh on 9/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    // MARK: - IBActions
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
        
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcome")
        self.present(mainView, animated: true, completion: nil)
    }
    

}
