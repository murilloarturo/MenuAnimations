//
//  MainViewController.swift
//  MenuAnimationsTest
//
//  Created by Arturo Murillo on 11/24/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    let transitionManager = TransitionManager()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.transitionManager.sourceViewController = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMainViewController (sender: UIStoryboardSegue){
        // bug? exit segue doesn't dismiss so we do it manually...
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // set transition delegate for our menu view controller
        let menu = segue.destinationViewController as MenuViewController
        menu.transitioningDelegate = self.transitionManager
        self.transitionManager.menuViewController = menu
    }

}
