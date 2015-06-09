//
//  Animations.swift
//  Animations
//
//  Created by Piotrek Demidowicz on 12.03.2015.
//  Copyright (c) 2015 Piotrek Demidowicz. All rights reserved.
//

import UIKit

extension UIView {
    
    // MARK: - Fade
    enum Fade {
        case In
        case Out
        case None
    }
    
    func fadeInAndOut(duration: NSTimeInterval, delay: NSTimeInterval? = 0, biggerAlpha: CGFloat? = 1, smallerAlpha: CGFloat? = 0, overgrowth: Bool? = false, completionClosure: (() -> Void)? = nil){
        
        self.alpha = smallerAlpha!
        self.transform = CGAffineTransformMakeScale(0, 0)
        if overgrowth! {
            self.resize(duration, scale: 1.2)
        }
        self.fade(duration/2, delay: delay!, fromAlpha: smallerAlpha!, toAlpha: biggerAlpha!) { () -> Void in
            self.fade(duration/2, delay: 0, fromAlpha: biggerAlpha!, toAlpha: smallerAlpha!) { () -> Void in
                completionClosure?()
            }
        }
    }
    
    
    func fade(fadeType: Fade, duration: NSTimeInterval, delay: NSTimeInterval? = 0, biggerAlpha: CGFloat? = 1, smallerAlpha: CGFloat? = 0, overgrowth: Bool = false, completionClosure: (() -> Void)? = nil){
        
        switch fadeType {
        case .In:
            self.fade(duration, delay: delay!, fromAlpha: smallerAlpha!, toAlpha: biggerAlpha!, completionClosure: completionClosure)
        case .Out:
            self.fade(duration, delay: delay!, fromAlpha: biggerAlpha!, toAlpha: smallerAlpha!, completionClosure: completionClosure)
        default:()
        }
        
        if overgrowth {
            self.resize(duration, scale: 1.2)
            
        }
        
    }
    
    private func fade(duration: NSTimeInterval, delay: NSTimeInterval, fromAlpha: CGFloat, toAlpha: CGFloat, completionClosure: (() -> Void)? = nil){
        self.alpha = fromAlpha
        
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: { () -> Void in
            self.alpha = toAlpha
            }) { (Bool) -> Void in
                completionClosure?()
        }
    }
    
    // MARK: - Rotating and spinning
    enum RotateDirection {
        case Left
        case Right
    }
    
    func rotate360Degrees(direction: RotateDirection, duration: CFTimeInterval? = 1.0, times: Double? = 1) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        var toValue = CGFloat(M_PI * (2.0 * times!))
        if direction == .Left {
            toValue = -toValue
        }
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration!
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func spinning(direction: RotateDirection, duration: Double, frequency: Double? = 1, hideOnCompletion: Bool? = false, completionClosure: (() -> Void)? = nil){
        startSpinning(direction, frequency: frequency!)
        NSTimer.scheduledTimerWithTimeInterval(duration, repeats: false) { () -> () in
            self.stopSpinning(hide: hideOnCompletion!)
            completionClosure?()
        }
    }
    
    func startSpinning(direction: RotateDirection, frequency: Double? = 1){
        self.alpha = 1.0
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        var toValue = CGFloat(M_PI * 2.0)
        if direction == .Left {
            toValue = -toValue
        }
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = frequency!
        rotateAnimation.repeatCount = Float.infinity
        self.layer.addAnimation(rotateAnimation, forKey: "spinning")
    }
    
    func stopSpinning(hide:Bool = false){
        if hide{
            self.alpha = 0.0
        }
        self.layer.removeAnimationForKey("spinning")
    }

    
    // MARK: - Flashing
    func flashing(duration: Double, frequency: Double? = 1, hideOnCompletion: Bool? = false, completionClosure: (() -> Void)? = nil){
        startFlashing(frequency: frequency!)
        NSTimer.scheduledTimerWithTimeInterval(duration, repeats: false) { () -> () in
            self.stopFlashing(hide: hideOnCompletion!)
            completionClosure?()
        }
    }
    
    func startFlashing(frequency: Double? = 1){
        let flashingAnimation = CABasicAnimation(keyPath: "opacity")
        flashingAnimation.fromValue = 0.0
        flashingAnimation.toValue = 1.0//CGFloat(M_PI * 2.0)
        flashingAnimation.duration = frequency!
        flashingAnimation.repeatCount = Float.infinity
        self.layer.addAnimation(flashingAnimation, forKey: "flashing")
    }
    
    func stopFlashing(hide:Bool = true){
        if hide{
            self.alpha = 0.0
        }
        self.layer.removeAnimationForKey("flashing")
    }
    
    
    //MARK: -Fly
    enum Directions {
        case Up
        case Down
        case Left
        case Right
    }
    
    enum FlyMode {
        case From
        case Away
    }
    
    
    func flyFrom(flyMode: FlyMode, pathLength: CGFloat, direction: Directions, duration: NSTimeInterval, delay:NSTimeInterval? = 0.0, completion:(()->Void)? = nil , fade: Fade) -> Void{
        var originalFrame = self.frame
        var newFrame = originalFrame
        var destinationFrame = CGRect()
        var pathLength = pathLength
        
        if flyMode == FlyMode.Away {
            pathLength = -pathLength
        }
       
        switch direction{
        case .Up:
            newFrame.origin.y += pathLength
        case .Down:
            newFrame.origin.y -= pathLength
        case .Left:
            newFrame.origin.x += pathLength
        case .Right:
            newFrame.origin.x -= pathLength
        default:
            ()
        }
        
        switch flyMode {
        case .From:
            self.frame = newFrame
            destinationFrame = originalFrame

        case .Away:
            destinationFrame = newFrame

        default :()
        }
  
        self.fade(fade, duration: duration, delay: delay)
        UIView.animateWithDuration(duration, delay: delay!, options: nil, animations: { () -> Void in
            self.frame = destinationFrame

        }) { (_) -> Void in
            completion?()
        }
        
    }
    
    //MARK: -Shake
    func simpleShake(repeatCount: Int? = 5, frequency: Double? = 0.1, successClosure: (() -> Void)? = nil){
        var shake = CABasicAnimation(keyPath: "position")
        shake.delegate = self
        var repeatCount = Float(repeatCount!)
        shake.duration = frequency!
        shake.repeatCount = repeatCount
        shake.autoreverses = true
        shake.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 5, self.center.y))
        shake.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 5, self.center.y))
        self.layer.addAnimation(shake, forKey: "position")
        
        var totalDuration = Double(repeatCount) * frequency!
        
        NSTimer.scheduledTimerWithTimeInterval((2 * totalDuration), repeats: false) { () -> () in
            successClosure?()
        }
    }
    
    //MARK: -Private
    private func resize(duration:CFTimeInterval, delay:NSTimeInterval = 0.0, scale: CGFloat){
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.transform=CGAffineTransformMakeScale(scale, scale)
            }) { (Bool) -> Void in
                UIView.animateWithDuration(duration * 0.3, animations: { () -> Void in
                    self.transform=CGAffineTransformIdentity
                })
        }
    }

}

extension NSTimer {
    class func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        
        
    }

    
    class NSTimerCallbackHolder : NSObject {
        var callback: () -> ()
        
        init(callback: () -> ()) {
            self.callback = callback
        }
        
        func tick(timer: NSTimer) {
            callback()
        }
    }
    
    class func scheduledTimerWithTimeInterval(ti: NSTimeInterval, repeats yesOrNo: Bool, closure: () -> ()) -> NSTimer! {
        var holder = NSTimerCallbackHolder(callback: closure)
        holder.callback = closure
        
        return NSTimer.scheduledTimerWithTimeInterval(ti, target: holder, selector: Selector("tick:"), userInfo: nil, repeats: yesOrNo)
    }
}
