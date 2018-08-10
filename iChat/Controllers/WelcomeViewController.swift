//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Max Goh on 8/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit
import ProgressHUD

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
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            loginUser()
        } else {
            ProgressHUD.showError("Email and Password is missing!")
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dissmissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" {
            if (passwordTextField.text == repeatPasswordTextField.text) {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords don't match!")
            }
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    @IBAction func backgroundTap(_ sender: Any) {
        dissmissKeyboard()
    }
    
    // MARK: Helpers
    
    func loginUser() {
        
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if (error != nil) {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            self.goToApp()
            
        }
        
    }
    
    func registerUser() {
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)

        cleanTextField()
        dissmissKeyboard()
        
    }
    
    func dissmissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
    
    //MARK: GoToApp
    
    func goToApp() {
        ProgressHUD.dismiss()
        cleanTextField()
        dissmissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    // MARK - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishReg" {
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
}
