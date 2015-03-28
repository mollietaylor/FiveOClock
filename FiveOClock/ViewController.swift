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

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for zone in timeZones {
            
            let zoneName = zone
            
            let rawDate = NSDateFormatter()
            rawDate.timeZone = NSTimeZone(name: zoneName)
            rawDate.dateFormat = "HH"
            
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
        
        println(afterFiveArray)
        
        refresh(self)
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        let randomIndex = arc4random_uniform(UInt32(afterFiveArray.count))
        let randomItem = afterFiveArray[Int(randomIndex)]
        
        label.text = randomItem["city"] as? String
        let timeString = randomItem["time"] as? String
        if let timeText = timeString?.componentsSeparatedByString(" ") {
            timeLabel.text = timeText[0]
        }
        
    }

}
