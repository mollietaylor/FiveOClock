//
//  ViewController.swift
//  FiveOClock
//
//  Created by Mollie on 3/27/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import iAd

//func adBanner() -> ADBannerView {
//    
//    // TODO: maybe move this down into bannerViewDidLoadAd?
//    var adBanner = ADBannerView(adType: ADAdType.Banner)
//    
//    adBanner.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 66)
//    
//    return adBanner
//    
//}

class ViewController: UIViewController, ADBannerViewDelegate {
    
    var timeZonesWithTimes = [[String:AnyObject]]()
    var afterFiveArray = [[String:AnyObject]]()
    var afterFiveCount = 0
    var i = 0
    
    var resetHour:String!
    var resetDay:String!
    var currentHour:String!
    var currentDay:String!

    @IBOutlet weak var adBanner: ADBannerView!
    @IBOutlet weak var grabADrinkLabel: UILabel!
    @IBOutlet weak var itsLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var grabConstraint: NSLayoutConstraint!
    @IBOutlet weak var itsConstraint: NSLayoutConstraint!
    
    var grabConstraintDefault:CGFloat = 0
    var itsConstraintDefault:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(adBanner)
        adBanner.delegate = self
        
        if view.frame.height < 568 {
            grabADrinkLabel.hidden = true
            itsLabel.text = "Grab a drink! It's"
            itsConstraint.constant -= 51
        }
        
        grabConstraintDefault = grabConstraint.constant
        itsConstraintDefault = itsConstraint.constant
        
        refreshTimeZoneData()
        refresh(self)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    func getHour() -> String {
        
        let hour = NSDateFormatter()
        hour.dateFormat = "HH" // 24-hour time
        let thisHour = hour.stringFromDate(NSDate())
        
        return thisHour
    }
    
    func getDay() -> String {
        
        let day = NSDateFormatter()
        day.dateStyle = NSDateFormatterStyle.ShortStyle
        let thisDay = day.stringFromDate(NSDate())
        
        return thisDay
    }
    
    func refreshTimeZoneData() {
        
        resetHour = getHour()
        resetDay = getDay()
        
        timeZonesWithTimes.removeAll()
        afterFiveArray.removeAll()
        afterFiveCount = 0
        i = 0
        
        for zone in timeZones {
            
            let zoneName = zone
            
            let rawDate = NSDateFormatter()
            rawDate.timeZone = NSTimeZone(name: zoneName)
            rawDate.dateFormat = "HH" // 24-hour time
            
            let formatter = NSDateFormatter()
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeZone = NSTimeZone(name: zoneName)
            let hour = rawDate.stringFromDate(NSDate()) as NSString
            let intHour = hour.integerValue
            let timeZoneTime = ["name":zoneName,"city":cities[i],"time":formatter.stringFromDate(NSDate()),"hour":hour]
            timeZonesWithTimes.append(timeZoneTime)
            
            if intHour >= 17 && intHour < 18 {
                afterFiveCount++
                afterFiveArray.append(timeZoneTime)
            }
            
            i++
            
        }
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        currentHour = getHour()
        currentDay = getDay()
        
        // if local hour or day has changed since last refreshTimeZoneData(), run it
        if currentDay != resetDay || currentHour != resetHour {
            refreshTimeZoneData()
        }
        
        let randomIndex = arc4random_uniform(UInt32(afterFiveArray.count))
        let randomItem = afterFiveArray[Int(randomIndex)]
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let zoneName = randomItem["name"] as String
        formatter.timeZone = NSTimeZone(name: zoneName)
        formatter.dateFormat = "mm"
        
        label.text = randomItem["city"] as? String
        timeLabel.text = "5:\(formatter.stringFromDate(NSDate()))"
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    // TODO: inside here, move banner down into view
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        layoutAnimated(true)
    }
    
    // TODO: figure out why this function isn't getting called
    // TODO: inside here, move banner out of view
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        println("failed to receive ad")
        println(error)
        layoutAnimated(true)
        
    }
    
    func layoutAnimated(animated: Bool) {
        
        let contentFrame = view.bounds
        let bannerFrame = adBanner.frame
        
        if adBanner.bannerLoaded {
            
            adBanner.hidden = false
            
            UIView.animateWithDuration(animated ? 0.25 : 0.0, animations: { () -> Void in
                
                self.adBanner.frame.origin.y = UIApplication.sharedApplication().statusBarFrame.height
                self.grabConstraint.constant = self.grabConstraintDefault
                self.itsConstraint.constant = self.itsConstraintDefault
                
            })
            
        } else {
            
            UIView.animateWithDuration(animated ? 0.5 : 0.0, animations: { () -> Void in
                
                println("banner not loaded")
                
                self.adBanner.frame.origin.y = -(self.adBanner.frame.height + UIApplication.sharedApplication().statusBarFrame.height)
                self.grabConstraint.constant = self.grabConstraintDefault - self.adBanner.frame.height
                self.itsConstraint.constant = self.itsConstraintDefault - self.adBanner.frame.height
                
            })
            
            adBanner.hidden = true
            
        }
        
        
    }

}
