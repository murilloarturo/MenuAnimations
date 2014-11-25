//
//  TransitionManager.swift
//  SwiftProject
//
//  Created by Arturo Murillo on 11/21/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

import UIKit

class TransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning {
    
    // private so can only be referenced within this object
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    
    private var statusBarBackground: UIView!
    
    private var interactive = false
    
    private var presenting = true
    
    var sourceViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
            self.enterPanGesture.edges = UIRectEdge.Left
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
            
            // create view to go behind status bar
            self.statusBarBackground = UIView()
            self.statusBarBackground.frame = CGRect(x: 0, y: 0, width: self.sourceViewController.view.frame.width, height: 20)
            self.statusBarBackground.backgroundColor = self.sourceViewController.view.backgroundColor
            
            // add to window rather than view controller
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            //UIApplication.sharedApplication().keyWindow?.addSubview(self.statusBarBackground)
        }
    }
    
    private var swipeGesture: UIPanGestureRecognizer!
    
    var menuViewController: UIViewController! {
        didSet {
            self.swipeGesture = UIPanGestureRecognizer()
            self.swipeGesture.addTarget(self, action:"handleSwipeGesture:")
            self.menuViewController.view.addGestureRecognizer(self.swipeGesture)
        }
    }
    
    func handleSwipeGesture(pan: UIScreenEdgePanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translationInView(pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds) * -0.5
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.Began:
            // set our interactive flag to true
            self.interactive = true

            // trigger the start of the transition
            self.menuViewController.performSegueWithIdentifier("UnwindSegue", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            // update progress of the transition
            self.updateInteractiveTransition(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            if(d > 0.1){
                // threshold crossed: finish
                self.finishInteractiveTransition()
            }
            else {
                // threshold not met: cancel
                self.cancelInteractiveTransition()
            }
        }

    }
    
    // TODO: We need to complete this method to do something useful
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translationInView(pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds) * 0.5
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.Began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            self.sourceViewController.performSegueWithIdentifier("presentMenu", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            // update progress of the transition
            self.updateInteractiveTransition(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            if(d > 0.2){
                // threshold crossed: finish
                self.finishInteractiveTransition()
            }
            else {
                // threshold not met: cancel
                self.cancelInteractiveTransition()
            }
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning){
        //TODO: Perform the animation
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let menuViewController = !self.presenting ? screens.from as MenuViewController : screens.to as MenuViewController
        let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = menuViewController.view
        let bottomView = bottomViewController.view
        
        // prepare menu items to slide in
        if (self.presenting){
            //if(self.interactive){
                self.offStageInteractiveMenuController(menuViewController) // offstage items: slide out
            //}else{
                //self.offStageMenuController(menuViewController) // offstage items: slide out
            //}
        }
        
        // add the both views to our view controller
        container.addSubview(menuView)
        container.addSubview(bottomView)
        //container.addSubview(self.statusBarBackground)
        
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: nil, animations: {
            
            if (self.presenting){
                //if(self.interactive){
                    self.onStageInteractiveMenuController(menuViewController) // onstage items: slide in
                //}else{
                    //self.onStageMenuController(menuViewController) // onstage items: slide in
                //}
            }
            else {
                //if(self.interactive){
                    self.offStageInteractiveMenuController(menuViewController) // offstage items: slide out
                //}else{
                    //self.offStageMenuController(menuViewController) // offstage items: slide out
                //}
            }
            
            }, completion: { finished in
                
                if(transitionContext.transitionWasCancelled()){
                    
                    transitionContext.completeTransition(false)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow?.addSubview(screens.from.view)
                    
                }
                else {
                    
                    transitionContext.completeTransition(true)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow?.addSubview(screens.to.view)
                }
                
                //UIApplication.sharedApplication().keyWindow?.addSubview(self.statusBarBackground)
                
        })
    }
    
    func offStage(amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(amount, 0)
    }
    
    func offStageMenuController(menuViewController: MenuViewController){
        
        menuViewController.view.alpha = 0
        
        // setup paramaters for 2D transitions for animations
        let topRowOffset  :CGFloat = 300
        let middleRowOffset :CGFloat = 150
        let bottomRowOffset  :CGFloat = 50
        
        menuViewController.textPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.textPostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.quotePostIcon.transform = self.offStage(-middleRowOffset)
        menuViewController.quotePostLabel.transform = self.offStage(-middleRowOffset)
        
        menuViewController.chatPostIcon.transform = self.offStage(-bottomRowOffset)
        menuViewController.chatPostLabel.transform = self.offStage(-bottomRowOffset)
        
        menuViewController.photoPostIcon.transform = self.offStage(topRowOffset)
        menuViewController.photoPostLabel.transform = self.offStage(topRowOffset)
        
        menuViewController.linkPostIcon.transform = self.offStage(middleRowOffset)
        menuViewController.linkPostLabel.transform = self.offStage(middleRowOffset)
        
        menuViewController.audioPostIcon.transform = self.offStage(bottomRowOffset)
        menuViewController.audioPostLabel.transform = self.offStage(bottomRowOffset)
        
        
        
    }
    
    func onStageMenuController(menuViewController: MenuViewController){
        
        // prepare menu to fade in
        menuViewController.view.alpha = 1
        
        menuViewController.textPostIcon.transform = CGAffineTransformIdentity
        menuViewController.textPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.quotePostIcon.transform = CGAffineTransformIdentity
        menuViewController.quotePostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.chatPostIcon.transform = CGAffineTransformIdentity
        menuViewController.chatPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.photoPostIcon.transform = CGAffineTransformIdentity
        menuViewController.photoPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.linkPostIcon.transform = CGAffineTransformIdentity
        menuViewController.linkPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.audioPostIcon.transform = CGAffineTransformIdentity
        menuViewController.audioPostLabel.transform = CGAffineTransformIdentity
        
    }
    
    func offStageInteractiveMenuController(menuViewController: MenuViewController){
        
        //menuViewController.view.alpha = 0
        
        // setup paramaters for 2D transitions for animations
        let topRowOffset  :CGFloat = 300
        //let middleRowOffset :CGFloat = 150
        //let bottomRowOffset  :CGFloat = 50
        
        menuViewController.textPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.textPostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.quotePostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.quotePostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.chatPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.chatPostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.photoPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.photoPostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.linkPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.linkPostLabel.transform = self.offStage(-topRowOffset)
        
        menuViewController.audioPostIcon.transform = self.offStage(-topRowOffset)
        menuViewController.audioPostLabel.transform = self.offStage(-topRowOffset)
        
        self.sourceViewController.navigationController?.view.transform = CGAffineTransformIdentity
        
    }
    
    func onStageInteractiveMenuController(menuViewController: MenuViewController){
        
        // prepare menu to fade in
        //menuViewController.view.alpha = 1
        
        menuViewController.textPostIcon.transform = CGAffineTransformIdentity
        menuViewController.textPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.quotePostIcon.transform = CGAffineTransformIdentity
        menuViewController.quotePostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.chatPostIcon.transform = CGAffineTransformIdentity
        menuViewController.chatPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.photoPostIcon.transform = CGAffineTransformIdentity
        menuViewController.photoPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.linkPostIcon.transform = CGAffineTransformIdentity
        menuViewController.linkPostLabel.transform = CGAffineTransformIdentity
        
        menuViewController.audioPostIcon.transform = CGAffineTransformIdentity
        menuViewController.audioPostLabel.transform = CGAffineTransformIdentity
        
        self.sourceViewController.navigationController?.view.transform = self.offStage(300)
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5;
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self;
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self;
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
}
