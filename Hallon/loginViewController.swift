//
//  loginViewController.swift
//  Hallon
//
//  Created by Paul Griffin on 21/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var errorMessageLabel: UILabel!

    @IBAction func loginButtonPressen(sender: AnyObject) {
        loginButton.hidden = true
        activityIndicator.hidden = false
        errorMessageLabel.hidden = true
        let scraper = HallonScraper(username: emailTextView.text ?? "", password: passwordTextField.text ?? "")
        scraper.getDataUsage(1, callback: {
            result in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                self.activityIndicator.hidden = true
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
