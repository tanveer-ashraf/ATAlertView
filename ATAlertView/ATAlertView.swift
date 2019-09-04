
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
    
    
    private func createAlertView(titleText:String!, messageText:String!, cancelButtonTitle:String!, otherButtonTitle:String!)
    {
        
        let alertWidth:CGFloat      = 250
        var alertHeight:CGFloat     = 150
        let alertFrame              = CGRect(x: 0, y: 0, width: alertWidth, height: alertHeight)
        
        alertView                       = UIView(frame: alertFrame)
        alertView.alpha                 = 0.0
        alertView.backgroundColor       = UIColor.white
        alertView.layer.cornerRadius    = 10
        alertView.layer.shadowColor     = UIColor.black.cgColor
        alertView.layer.shadowOffset    = CGSize(width: 0, height: 5)
        alertView.layer.shadowOpacity   = 0.3
        alertView.layer.shadowRadius    = 10.0
        
        if(backgroundColor != nil){
            
            alertView.backgroundColor       = backgroundColor;
        }
        
        
        
        //Create Title
        
        let title:UILabel   = UILabel(frame: CGRect(x: 5, y: 5, width: alertWidth - 10, height:20))
        title.textAlignment = NSTextAlignment.center
        title.text          = titleText
        alertView.addSubview(title)
        
        
        //CreateMessage
        let message:UILabel   = UILabel(frame: CGRect(x: 5, y: 25, width: alertWidth - 10, height: CGFloat.greatestFiniteMagnitude))
        message.numberOfLines = 0
        message.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        message.text = messageText
        message.font = UIFont.systemFont(ofSize: 12)
        
        message.sizeToFit()
        alertHeight = message.frame.height + 35
        alertView.frame.size = CGSize(width: alertWidth, height: alertHeight)
        
        message.frame = CGRect(x: 5, y: 30, width: alertWidth - 10, height: message.frame.height)
        message.textAlignment = NSTextAlignment.center
        alertView.addSubview(message)
        
        
        
        if(otherButtonTitle != nil && cancelButtonTitle != nil){
            
            
            alertHeight += 50
            alertView.frame.size = CGSize(width: alertWidth, height: alertHeight)
            addButtonWithTitle(title: cancelButtonTitle, frame: CGRect(x: 0, y: alertHeight - 40, width: alertWidth/2, height: 40))
            addButtonWithTitle(title: otherButtonTitle, frame: CGRect(x: alertWidth/2, y: alertHeight - 40, width: alertWidth/2, height: 40))
            
            
        }else{
            
            if(cancelButtonTitle != nil){
                
                alertHeight += 60
                alertView.frame.size = CGSize(width: alertWidth, height: alertHeight)
                addButtonWithTitle(title: cancelButtonTitle, frame: CGRect(x: 0, y: alertHeight - 40, width: alertWidth, height: 40))
                
            }else if(otherButtonTitle != nil){
                
                alertHeight += 60
                alertView.frame.size = CGSize(width: alertWidth, height: alertHeight)
                addButtonWithTitle(title: otherButtonTitle, frame: CGRect(x: 0, y: alertHeight - 40, width: alertWidth, height: 40))
                
                
            }
        }
        
    }
    
    
    
    
    //==================== Create Buttons //===================
    private func addButtonWithTitle(title:String, frame:CGRect)
    {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: UIControl.State.normal)
        btn.backgroundColor = UIColor.white
        btn.frame = frame
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 0.5
        btn.tag = tag
        tag += 1
        
        btn.addTarget(self, action:#selector(dismissAlert(sender:)), for: .touchUpInside)
        
        
        alertView.addSubview(btn)
    }
    
    
    func showAlertToView(view: UIView, title:String, message:String, cancelButtonTitle:String!,  otherButtonTitle:String!, presentaitonStyle:ATAlertViewPresentationStyle ,dismissStyle: ATAlertViewDismissStyle)
    {
        
        parentView = view
        if(alertView == nil){
            
            
            createAlertView(titleText: title, messageText: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle)
            createBackgroundOverlay()
        }
        
        alertPresentationStyle = presentaitonStyle
        alertDismissStyle = dismissStyle
        
        animator = UIDynamicAnimator(referenceView: parentView)
        
        // Create the dark background view and the alert view
        parentView.addSubview(alertView)
        showAlert(withPresentationStyle: alertPresentationStyle, andDismissStyle: alertDismissStyle)
        
        
        
    }
    
    
    private func createBackgroundOverlay()
    {
        overlayView = UIView(frame: parentView.bounds)
        
        if(overlayBackgroundColor != nil){
            
            overlayView.backgroundColor = overlayBackgroundColor
            
        }else{
            
            overlayView.backgroundColor = UIColor.black
        }
        
        
        overlayView.alpha = 0.0
        parentView.addSubview(overlayView)
    }
    
    
    private func showAlert(withPresentationStyle: ATAlertViewPresentationStyle, andDismissStyle:ATAlertViewDismissStyle)
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
        
        
        UIView.animate(withDuration: 0.4, animations:{
            
            self.overlayView.alpha = 0.7
            
        })
        
        
        alertView.alpha = 1.0
        
        
        if(alertPresentationStyle == ATAlertViewPresentationStyle.SmoothUp){
            
            
            alertView.frame = CGRect(x: parentView.center.x - (alertView.frame.width/2), y: 0, width: alertView.frame.size.width, height: alertView.frame.size.height)
            
            let gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVector(dx: 0, dy: 10)
            animator.addBehavior(gravity)
            
            
            let collision = UICollisionBehavior(items: [alertView])
            
            collision.addBoundary(withIdentifier: "alertBoundry" as NSCopying, from:CGPoint(x: 0, y: parentView.center.y + (alertView.frame.size.height/2)) , to: CGPoint(x: parentView.frame.size.width, y: parentView.center.y + (alertView.frame.size.height/2)))
            animator.addBehavior(collision)
            
            
            
        }else if(alertPresentationStyle == ATAlertViewPresentationStyle.SmoothDown){
            
            
            alertView.frame = CGRect(x: parentView.center.x - (alertView.frame.width/2), y: parentView.frame.size.height, width: alertView.frame.size.width, height: alertView.frame.size.height)
            
            
            let gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVector(dx: 0, dy: -10)
            animator.addBehavior(gravity)
            
            
            let collision = UICollisionBehavior(items: [alertView])
            collision.addBoundary(withIdentifier: "alertBoundry" as NSCopying, from:CGPoint(x: 0, y: parentView.center.y - (alertView.frame.size.height/2)) , to: CGPoint(x: parentView.frame.size.width, y: parentView.center.y - (alertView.frame.size.height/2)))
            animator.addBehavior(collision)
            
            
            
        }else{
            
            if(alertPresentationStyle == ATAlertViewPresentationStyle.HardDown){
                
                alertView.frame = CGRect(x: 0, y: parentView.frame.size.height, width: alertView.frame.size.width, height: alertView.frame.size.height)
                
            }
            
            let snapVehaviour : UISnapBehavior = UISnapBehavior(item: alertView, snapTo: parentView.center)
            animator.addBehavior(snapVehaviour)
        }
        
        
        
    }
    
    
    private func createPanGesture()
    {
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector(("handlePan:"))) as UIPanGestureRecognizer
        
        parentView.addGestureRecognizer(panGesture)
        
    }
    
    
    private func createTapGesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("handleTap:"))) as UITapGestureRecognizer
        
        overlayView.addGestureRecognizer(tapGesture)
        
    }
    
    
    @objc internal func dismissAlert(sender:UIButton!)
    {
        
        animator.removeAllBehaviors()
        
        if(alertDismissStyle == ATAlertViewDismissStyle.HardDown){
            
            
            let gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVector(dx: 0, dy: 10)
            animator.addBehavior(gravity)
            
            let itemBehaviour : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
            itemBehaviour.addAngularVelocity(CGFloat(-Double.pi/2), for: alertView)
            animator.addBehavior(itemBehaviour)
            
        }else if(alertDismissStyle == ATAlertViewDismissStyle.HardUp){
            
            let gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            gravity.gravityDirection = CGVector(dx: 0, dy: -10)
            animator.addBehavior(gravity)
            
            let itemBehaviour : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
            itemBehaviour.addAngularVelocity(CGFloat(Double.pi), for: alertView)
            animator.addBehavior(itemBehaviour)
            
            
            
        }else{
            
            let Push : UIPushBehavior = UIPushBehavior(items: [alertView], mode: UIPushBehavior.Mode.instantaneous)
            Push.setAngle(CGFloat(Double.pi), magnitude: 20.0)
            animator.addBehavior(Push)
            
            
            let gravity : UIGravityBehavior = UIGravityBehavior(items: [alertView])
            
            if (alertDismissStyle == ATAlertViewDismissStyle.SmoothUp){
                
                
                gravity.gravityDirection = CGVector(dx: 0, dy: -10)
                
            }else if (alertDismissStyle == ATAlertViewDismissStyle.SmoothDown){
                
                gravity.gravityDirection = CGVector(dx: 0, dy: 10)
            }
            
            animator.addBehavior(gravity)
            
            
            
        }
        
        
        UIView.animate(withDuration: 0.4, animations:{
            
            self.overlayView.alpha = 0.0
        }, completion: {
            (value: Bool) in
            self.alertView.removeFromSuperview()
            self.alertView = nil
            self.tag = 0
            
            if(sender != nil){
                
                if(self.delegate != nil){
                    
                    self.delegate.didTapButonAtIndex(index: sender.tag, buttonTitle:sender.title(for: UIControl.State.normal)!);
                }
                
            }
        })
        
        
    }
    
    
    internal func handlePan(sender: UIPanGestureRecognizer) {
        
        if (alertView != nil) {
            let panLocationInView = sender.location(in: parentView)
            let panLocationInAlertView = sender.location(in: alertView)
            
            if sender.state == UIGestureRecognizer.State.began {
                animator.removeAllBehaviors()
                
                let offset = UIOffset(horizontal: panLocationInAlertView.x - alertView.bounds.midX, vertical: panLocationInAlertView.y - alertView.bounds.midY);
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                animator.addBehavior(attachmentBehavior)
                
                
            }else if sender.state == UIGestureRecognizer.State.changed {
                attachmentBehavior.anchorPoint = panLocationInView
                
                
            }else if sender.state == UIGestureRecognizer.State.ended {
                animator.removeAllBehaviors()
                
                
                
                if sender.translation(in: parentView).y > 100 {
                    
                    dismissAlert(sender: nil)
                    
                    
                }else{
                    
                    snapBehavior = UISnapBehavior(item: alertView, snapTo: parentView.center)
                    animator.addBehavior(snapBehavior)
                }
            }
        }
        
    }
    
    
    
    internal func handleTap(sender: UITapGestureRecognizer) {
        
        if (alertView != nil) {
            
            dismissAlert(sender: nil)
        }
        
    }
    
    
    
}
