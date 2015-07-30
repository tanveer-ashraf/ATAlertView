//
//  ViewController.swift
//  ATAlertView
//
//  Created by AT on 7/10/15.
//  Copyright (c) 2015 cellzone. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ATAlertviewDelegate {

    var alert : ATAlertView!
    
    @IBAction func showAlert(sender: AnyObject) {
        
        alert = ATAlertView()
        alert.delegate = self
        alert.showAlertToView(self.view,title: "Sample Title", message: "Sample message Sample message Sample message", cancelButtonTitle: "Ok", otherButtonTitle: nil,  presentaitonStyle: ATAlertViewPresentationStyle.SmoothDown, dismissStyle: ATAlertViewDismissStyle.SmoothUp)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didTapButonAtIndex(index: NSInteger, buttonTitle: String) {
        
        
    }

}

