//
//  FetchViewController.swift
//  TheBackgrounder
//
//  Created by Ray Fix on 12/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit

class FetchViewController: UIViewController {
  
  @IBOutlet weak var updateLabel: UILabel?
  var time: NSDate?
  
  func fetch(completion: () -> Void) {
    time = NSDate()
    completion()
  }
  
  func updateUI() {
    if let time = time {
      let formatter = NSDateFormatter()
      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .LongStyle
      updateLabel?.text = formatter.stringFromDate(time)
    }
    else {
      updateLabel?.text = "Not yet updated"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
  }
  
  @IBAction func didTapUpdate(sender: UIButton) {
    fetch { self.updateUI() }
  }
}
