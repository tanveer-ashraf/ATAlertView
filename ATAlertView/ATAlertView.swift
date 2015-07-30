//
//  ATAlertView.swift
//  ATAlertView
//
//  Created by Tanveer Ashraf on 7/10/15.
//  Copyright (c) 2015 AT. All rights reserved.
//

import UIKit



public enum ATAlertViewGestureType {
    case Pan, Tap
}

public enum ATAlertViewPresentationStyle {
    case SmoothUp, SmoothDown, HardUp, HardDown
}

public enum ATAlertViewDismissStyle {
    case SmoothUp, SmoothDown, HardUp, HardDown
}


protocol ATAlertviewDelegate{
    func didTapButonAtIndex(index: NSInteger, buttonTitle: String)
}

class ATAlertView: NSObject {
    
    
    //================ Private Properties ===================//
    private var alertView           : UIView!
    private var animator            : UIDynamicAnimator!
    private var attachmentBehavior  : UIAttachmentBehavior!
    private var snapBehavior        : UISnapBehavior!
    private var parentView          : UIView!
    private var tag :Int = 0
    
    var overlayView         : UIView!
    var alertDismissStyle       = ATAlertViewDismissStyle.SmoothDown
    var alertPresentationStyle  = ATAlertViewPresentationStyle.SmoothUp
    
    var delegate:ATAlertviewDelegate! = nil
    var alertDismissGesture = ATAlertViewGestureType.Pan;
    
    internal var isGestureModeEnable: Bool = true
    
    
    
    //============== UI component makeup ================//
    var overlayBackgroundColor  : UIColor!
    var backgroundColor         : UIColor!   //Background color of alertView
    var titleColor              : UIColor!
    var messageColor            : UIColor!
    
    
    
    override init() {
        
        
    }
    
    
    func createAlertView(titleText:String!, messageText:String!, cancelButtonTitle:String!, otherButtonTitle:String!)
    {
        
        var alertWidth:CGFloat      = 250
        var alertHeight:CGFloat     = 150
        var alertFrame              = CGRectMake(0, 0, alertWidth, alertHeight)
        
        alertView                       = UIView(frame: alertFrame)
        alertView.alpha                 = 0.0
        alertView.backgroundColor       = UIColor.whiteColor()
        alertView.layer.cornerRadius    = 10
        alertView.layer.shadowColor     = UIColor.blackColor().CGColor
        alertView.layer.shadowOffset    = CGSizeMake(0, 5)
        alertView.layer.shadowOpacity   = 0.3
        alertView.layer.shadowRadius    = 10.0
        
        if(backgroundColor != nil){
            
            alertView.backgroundColor       = backgroundColor;
        }
        
        
        
        //Create Title
        
        var title:UILabel   = UILabel(frame: CGRectMake(5, 5, alertWidth - 10, 20))
        title.textAlignment = NSTextAlignment.Center
        title.text          = titleText
        alertView.addSubview(title)
        
        
        //CreateMessage
        var message:UILabel   = UILabel(frame: CGRectMake(5, 25, alertWidth - 10, CGFloat.max))
        message.numberOfLines = 0
        message.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        message.text = messageText
        message.font = UIFont.systemFontOfSize(12)
        
        message.sizeToFit()
        alertHeight = message.frame.height + 35
        alertView.frame.size = CGSizeMake(alertWidth,alertHeight)
        
        message.frame = CGRectMake(5, 30, alertWidth - 10, message.frame.height)
        message.textAlignment = NSTextAlignment.Center
        alertView.addSubview(message)
        
        
        
        if(otherButtonTitle != nil && cancelButtonTitle != nil){
            
            
            alertHeight += 50
            alertView.frame.size = CGSizeMake(alertWidth,alertHeight)
            addButtonWithTitle(cancelButtonTitle, frame: CGRectMake(0, alertHeight - 40, alertWidth/2, 40))
            addButtonWithTitle(otherButtonTitle, frame: CGRectMake(alertWidth/2, alertHeight - 40, alertWidth/2, 40))
            
            
        }else{
            
            if(cancelButtonTitle != nil){
                
                alertHeight += 60
                alertView.frame.size = CGSizeMake(alertWidth,alertHeight)
                addButtonWithTitle(cancelButtonTitle, frame: CGRectMake(0, alertHeight - 40, alertWidth, 40))
                
            }else if(otherButtonTitle != nil){
                
                alertHeight += 60
                alertView.frame.size = CGSizeMake(alertWidth,alertHeight)
                addButtonWithTitle(otherButtonTitle, frame: CGRectMake(0, alertHeight - 40, alertWidth, 40))
                
                
            }
        }
        
    }
    
    
    
    
    //==================== Create Buttons //===================
    func addButtonWithTitle(title:String, frame:CGRect)
    {
        let btn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        btn.setTitle(title, forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.whiteColor()
        btn.frame = frame
        btn.layer.borderColor = UIColor.grayColor().CGColor
        btn.layer.borderWidth = 0.5
        btn.tag = tag
        tag++
        
        btn.addTarget(self, action: Selector("dismissAlert:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        alertView.addSubview(btn)
    }
    
    
    func showAlertToView(view: UIView, title:String, message:String, cancelButtonTitle:String!,  otherButtonTitle:String!, presentaitonStyle:ATAlertViewPresentationStyle ,dismissStyle: ATAlertViewDismissStyle)
    {
        
        parentView = view
        if(alertView == nil){
            
            
            createAlertView(title, messageText: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle)
            createBackgroundOverlay()
        }
        
        alertPresentationStyle = presentaitonStyle
        alertDismissStyle = dismissStyle
        
        animator = UIDynamicAnimator(referenceView: parentView)
        
        // Create the dark background view and the alert view
        parentView.addSubview(alertView)
        showAlert(alertPresentationStyle, andDismissStyle: alertDismissStyle)
        
        
        
    }
    
    
    func createBackgroundOverlay()
    {
        overlayView = UIView(frame: parentView.bounds)
        
        if(overlayBackgroundColor != nil){
            
            overlayView.backgroundColor = overlayBackgroundColor
            
        }else{
            
            overlayView.backgroundColor = UIColor.blackColor()
        }
        
        
        overlayView.alpha = 0.0
        parentView.addSubview(overlayView)
    }
    
    
    func showAlert(withPresentationStyle: ATAlertViewPresentationStyle, andDismissStyle:ATAlertViewDismissStyle)
    {
        
        if(isGestureModeEnable){
            
            if(alertDismissGesture == ATAlertViewGestureType.Pan){
                
                createPanGesture()
                
            }else if(alertDismissGesture == ATAlertViewGestureType.Tap){
                
                createTapGesture()
                
            }else{
                
                createPanGesture()
            }
        }
        
        
        animator.removeAllBehaviors()
        
        
        UIView.animateWithDuration(0.4, animations: {
            
            self.overlayView.alpha = 0.7
            
        })
        
        
        alertView.alpha = 1.0
        
        
        if(alertPresentationStyle == ATAlertViewPresentationStyle.SmoothUp){
            
            
            alertView.frame = CGRectMake(parentView.center.x - (alertView.frame.width/2), 0, alertView.frame.size.width, alertView.frame.size.height)
            
            var gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVectorMake(0, 10)
            animator.addBehavior(gravity)
            
            
            var collision = UICollisionBehavior(items: [alertView])
            collision.addBoundaryWithIdentifier("alertBoundry", fromPoint:CGPointMake(0, parentView.center.y + (alertView.frame.size.height/2)) , toPoint: CGPointMake(parentView.frame.size.width, parentView.center.y + (alertView.frame.size.height/2)))
            animator.addBehavior(collision)
            
            
            
        }else if(alertPresentationStyle == ATAlertViewPresentationStyle.SmoothDown){
            
            
            alertView.frame = CGRectMake(parentView.center.x - (alertView.frame.width/2), parentView.frame.size.height, alertView.frame.size.width, alertView.frame.size.height)
            
            
            var gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVectorMake(0, -10)
            animator.addBehavior(gravity)
            
            
            var collision = UICollisionBehavior(items: [alertView])
            collision.addBoundaryWithIdentifier("alertBoundry", fromPoint:CGPointMake(0, parentView.center.y - (alertView.frame.size.height/2)) , toPoint: CGPointMake(parentView.frame.size.width, parentView.center.y - (alertView.frame.size.height/2)))
            animator.addBehavior(collision)
            
            
            
        }else{
            
            if(alertPresentationStyle == ATAlertViewPresentationStyle.HardDown){
                
                alertView.frame = CGRectMake(0, parentView.frame.size.height, alertView.frame.size.width, alertView.frame.size.height)
                
            }
            
            var snapVehaviour : UISnapBehavior = UISnapBehavior(item: alertView, snapToPoint: parentView.center)
            animator.addBehavior(snapVehaviour)
        }
        
        
        
    }
    
    
    func createPanGesture()
    {
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePan:")) as UIPanGestureRecognizer
        
        parentView.addGestureRecognizer(panGesture)
        
    }
    
    
    func createTapGesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:")) as UITapGestureRecognizer
        
        overlayView.addGestureRecognizer(tapGesture)
        
    }
    
    
    func dismissAlert(sender:UIButton!)
    {
        
        animator.removeAllBehaviors()
        
        if(alertDismissStyle == ATAlertViewDismissStyle.HardDown){
            
            
            var gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVectorMake(0, 10)
            animator.addBehavior(gravity)
            
            var itemBehaviour : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
            itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), forItem: alertView)
            animator.addBehavior(itemBehaviour)
            
        }else if(alertDismissStyle == ATAlertViewDismissStyle.HardUp){
            
            var gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVectorMake(0, -10)
            animator.addBehavior(gravity)
            
            var itemBehaviour : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
            itemBehaviour.addAngularVelocity(CGFloat(M_PI_2), forItem: alertView)
            animator.addBehavior(itemBehaviour)
            
            
            
        }else{
            
            var Push : UIPushBehavior = UIPushBehavior(items: [alertView], mode: UIPushBehaviorMode.Instantaneous)
            Push.setAngle(CGFloat(M_PI_2), magnitude: 20.0)
            animator.addBehavior(Push)
            
            
            var gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            
            if (alertDismissStyle == ATAlertViewDismissStyle.SmoothUp){
                
                
                gravity.gravityDirection = CGVectorMake(0, -10)
                
            }else if (alertDismissStyle == ATAlertViewDismissStyle.SmoothDown){
                
                gravity.gravityDirection = CGVectorMake(0, 10)
            }
            
            animator.addBehavior(gravity)
            
            
            
        }
        
        
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.alertView.removeFromSuperview()
                self.alertView = nil
                self.tag = 0
                
                if(sender != nil){
                    
                    if(self.delegate != nil){
                        
                        self.delegate.didTapButonAtIndex(sender.tag, buttonTitle:sender.titleForState(UIControlState.Normal)!);
                    }
                    
                }
        })
        
        
    }
    
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (alertView != nil) {
            let panLocationInView = sender.locationInView(parentView)
            let panLocationInAlertView = sender.locationInView(alertView)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertView.x - CGRectGetMidX(alertView.bounds), panLocationInAlertView.y - CGRectGetMidY(alertView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                animator.addBehavior(attachmentBehavior)
                
                
            }else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
                
                
            }else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeAllBehaviors()
                
                
                
                if sender.translationInView(parentView).y > 100 {
                    
                    dismissAlert(nil)
                    
                    
                }else{
                    
                    snapBehavior = UISnapBehavior(item: alertView, snapToPoint: parentView.center)
                    animator.addBehavior(snapBehavior)
                }
            }
        }
        
    }
    
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        if (alertView != nil) {
            
            dismissAlert(nil)
        }
        
    }
    
    
    
}
