//
//  loginViewController.swift
//  Hallon
//
//  Created by Paul Griffin on 21/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

class loginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
    }

    @IBAction func loginButtonPressen(sender: AnyObject) {
        loginButton.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        errorMessageLabel.hidden = true
        let scraper = HallonScraper(username: emailTextView.text ?? "", password: passwordTextField.text ?? "")
        scraper.getDataUsage(2, callback: {
            result in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                self.loginButton.hidden = false
                switch result{
                case .Success(value: _):
                    self.dismissViewControllerAnimated(true, completion: nil)
                case .Error(error: _):
                    self.errorMessageLabel.hidden = false
                    break
                }
            }
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            let nextView = textField.superview?.viewWithTag(textField.tag+1)
            if let nextView = nextView as? UITextView {
                nextView.becomeFirstResponder()
            }else if let button = nextView as? UIButton {
                button.sendActionsForControlEvents(.TouchUpInside)
            }
        }
        return true
    }
    /*
    -(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField.returnKeyType==UIReturnKeyNext) {
    UIView *next = [[textField superview] viewWithTag:textField.tag+1];
    [next becomeFirstResponder];
    } else if (textField.returnKeyType==UIReturnKeyDone) {
    [textField resignFirstResponder];
    }
    return YES;
    }
*/
    

}
