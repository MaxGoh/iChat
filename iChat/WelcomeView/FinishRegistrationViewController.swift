//
//  FinishRegistrationViewController.swift
//  iChat
//
//  Created by Max Goh on 9/8/18.
//  Copyright © 2018 Max Goh. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK - IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cleanTextField()
        dissmissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dissmissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && nameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                self.registerUser()
            }
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    // MARK - Helpers
    
    func registerUser() {
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDictionary: Dictionary = [
            kFIRSTNAME : nameTextField.text!,
            kLASTNAME : surnameTextField.text!,
            kFULLNAME : fullName,
            kCOUNTRY : countryTextField.text!,
            kCITY: cityTextField.text!,
            kPHONE: phoneTextField.text!
        ] as [String: Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                let avatarIMG = UIImageJPEGRepresentation(avatarInitials, 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
        } else {
            let avatarData = UIImageJPEGRepresentation(avatarImage!, 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary)

        }
    }
    
    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp() {
        cleanTextField()
        dissmissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dissmissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextField() {
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    

}
