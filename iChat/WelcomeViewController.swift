//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Max Goh on 8/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBActions

    @IBAction func loginButtonPressed(_ sender: Any) {
        dissmissKeyboard()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dissmissKeyboard()
    }
    @IBAction func backgroundTap(_ sender: Any) {
        dissmissKeyboard()
    }
    
    // MARK: Helpers
    
    func dissmissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
}
