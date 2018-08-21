//
//  ViewController.swift
//  BiometricAuthenticationExample
//
//  Created by roninprogrammer on 07/01/18.
//  Copyright © 2018 roninprogrammer. All rights reserved.
//

import UIKit
import BiometricAuthentication

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        view.endEditing(true)
        
        // show success alert
        showLoginSucessAlert()
    }
    
    @IBAction func biometricAuthenticationClicked(_ sender: Any) {
        
        // start authentication
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
            
            // authentication successful
            self.showLoginSucessAlert()
            
        }, failure: { [weak self] (error) in
            
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                return
            }
                
            // show alternatives on fallback button clicked
            else if error == .fallback {
                
                // here we're entering username and password
                self?.txtUsername.becomeFirstResponder()
            }
                
                // No biometry enrolled in this device, ask user to register fingerprint or face
            else if error == .biometryNotEnrolled {
                self?.showGotoSettingsAlert(message: error.message())
            }
                
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
            else if error == .biometryLockedout {
                self?.showPasscodeAuthentication(message: error.message())
            }
                
                // show error on authentication failed
            else {
                self?.showErrorAlert(message: error.message())
            }
        })
    }
    
    // show passcode authentication
    func showPasscodeAuthentication(message: String) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message, success: {
            // passcode authentication success
            self.showLoginSucessAlert()
            
        }) { (error) in
            print(error.message())
        }
    }
}

// MARK: - Alerts
extension ViewController {
    
    func showAlert(title: String, message: String) {
        
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
}
