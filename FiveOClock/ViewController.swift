//
//  ViewController.swift
//  FiveOClock
//
//  Created by Mollie on 3/27/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

// TODO: after 60 seconds, reload (label only) to show new time

class ViewController: UIViewController {
    
    var timeZonesWithTimes = [[String:AnyObject]]()
    var afterFiveArray = [[String:AnyObject]]()
    var afterFiveCount = 0
    var i = 0
    
    var resetHour:String!
    var resetDay:String!
    var currentHour:String!
    var currentDay:String!

    @IBOutlet weak var grabADrinkLabel: UILabel!
    @IBOutlet weak var itsLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if view.frame.height < 568 {
            grabADrinkLabel.hidden = true
            itsLabel.text = "Grab a drink! It's"
        }
        
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
        println(resetHour)
        println(resetDay)
        println(currentHour)
        println(currentDay)
        
        // if local hour or day has changed since last refreshTimeZoneData(), run it
        if currentDay != resetDay || currentHour != resetHour {
            println("refresh time zone data")
            refreshTimeZoneData()
        }
        
        let minutes = NSDateFormatter()
        minutes.dateFormat = "mm"
        
        let randomIndex = arc4random_uniform(UInt32(afterFiveArray.count))
        let randomItem = afterFiveArray[Int(randomIndex)]
        
        label.text = randomItem["city"] as? String
        // TODO: make sure this works right when minutes begins with 0
        timeLabel.text = "5:\(minutes.stringFromDate(NSDate()))"
        
    }

}
