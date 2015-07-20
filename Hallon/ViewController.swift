//
//  ViewController.swift
//  Hallon
//
//  Created by Paul Griffin on 17/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dataUsedLabel: UILabel!
    @IBOutlet weak var dataMaxLabel: UILabel!
    @IBOutlet weak var callsLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        HallonScraper(username: "paul.griffin@hotmail.com", password: "urxb72r4").getDataUsage{
            switch $0{
            case .Success(let usage):
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.dataMaxLabel.text = String(format: "av %.1f GB", arguments: [usage.dataMax])
                    self.dataUsedLabel.text = String(format: "%.1f", arguments: [usage.dataUsed])
                    self.callsLabel.text = String(format: "%.0f", arguments: [usage.callsUsed])
                    self.messagesLabel.text = String(format: "%.0f", arguments: [usage.textsUsed])
                }
            case .Error(let error):
                print(error)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

