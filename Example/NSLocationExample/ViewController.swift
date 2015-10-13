//
//  ViewController.swift
//  NSLocationExample
//
//  Created by zekunyan on 15/10/5.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit
import NSLocation

class ViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var actionTextField: UITextField!
    @IBOutlet weak var durationSegmented: UISegmentedControl!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var animationTypeSegmented: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = NSLocation()
    }

}

