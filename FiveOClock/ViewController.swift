//
//  ViewController.swift
//  FiveOClock
//
//  Created by Mollie on 3/27/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timeZonesWithTimes = [[:]]
    var afterFiveArray = [[:]]
    var afterFiveCount = 0
    var i = 0

    @IBOutlet weak var label: UILabel!
    
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
        
        let randomIndex = arc4random_uniform(UInt32(afterFiveArray.count))
        let randomItem = afterFiveArray[Int(randomIndex)]
        
        label.text = randomItem["city"] as? String
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        let randomIndex = arc4random_uniform(UInt32(afterFiveArray.count))
        let randomItem = afterFiveArray[Int(randomIndex)]
        
        label.text = randomItem["city"] as? String
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
