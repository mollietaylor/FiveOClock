//
//  ViewController.swift
//  FiveOClock
//
//  Created by Mollie on 3/27/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import iAd
import StoreKit

class ViewController: UIViewController, UIActionSheetDelegate, ADBannerViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var timeZonesWithTimes = [[String:AnyObject]]()
    var afterFiveArray = [[String:AnyObject]]()
    var afterFiveCount = 0
    var i = 0
    
    var resetHour:String!
    var resetDay:String!
    var currentHour:String!
    var currentDay:String!
    
    var productID = "com.proximityviz.FiveOClock.RemoveAds"
    var adsRemoved = false

    @IBOutlet weak var adBanner: ADBannerView!
    @IBOutlet weak var grabADrinkLabel: UILabel!
    @IBOutlet weak var itsLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var grabConstraint: NSLayoutConstraint!
    @IBOutlet weak var itsConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeAdsButton: UIButton!
    
    var grabConstraintDefault:CGFloat = 0 // 8
    var itsConstraintDefault:CGFloat = 0 // 59
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grabConstraintDefault = grabConstraint.constant
                itsConstraintDefault = itsConstraint.constant
        
        if view.frame.height < 568 {
            grabADrinkLabel.hidden = true
            itsLabel.text = "Grab a drink! It's"
            itsConstraint.constant -= 51
            itsConstraintDefault -= 51
        }
        
        timeLabel.textColor = UIColor(red:0.01, green:0.75, blue:1, alpha:1)
        refreshButton.setTitleColor(UIColor(red:0.01, green:0.75, blue:1, alpha:1), forState: UIControlState.Normal)
        
        // TODO: check NSUserDefaults to see if ads have been removed
        // if true, remove the ad button and hide the ad
        adsRemoved = NSUserDefaults.standardUserDefaults().boolForKey("adsRemoved")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if adsRemoved {
            adBanner.hidden = true
            removeAdsButton.hidden = true
            moveAdBanner()
            println("test")
        } else {
            adBanner.delegate = self
        }
        
        refreshTimeZoneData()
        refresh(self)
        
        // IAP
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
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
    
    // MARK: Ads
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        layoutAnimated(true)
    }
    
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
                self.moveAdBanner()
                
            })
            
            adBanner.hidden = true
            
        }
        
    }
    
    func moveAdBanner() {
        
        adBanner.frame.origin.y = -(adBanner.frame.height + UIApplication.sharedApplication().statusBarFrame.height)
        grabConstraint.constant = grabConstraintDefault - adBanner.frame.height
        itsConstraint.constant = itsConstraintDefault - adBanner.frame.height
        println("move")
        
    }
    
    // MARK: Remove Ads
    @IBAction func tapToRemoveAds(sender: AnyObject) {

        // UIActionSheet
        let actionSheet = UIActionSheet(title: "How would you like to remove ads?", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "Purchase", "Restore")
        actionSheet.showInView(view)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            purchase()
        } else if buttonIndex == 1 {
            restore()
        }
        
    }
    
    func purchase() {
        
        if SKPaymentQueue.canMakePayments() {
            
            let productIDSet = NSSet(object: productID)
            var productsRequest = SKProductsRequest(productIdentifiers: productIDSet)
            productsRequest.delegate = self
            productsRequest.start()
            
        } else {
            // alert user that they can't make a purchase
        }
        
    }
    
    func restore() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func buyProduct(product: SKProduct) {
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        let count = response.products.count
        if count > 0 {
            
            let validProduct = response.products[0] as SKProduct
            if validProduct.productIdentifier == productID {
                
                buyProduct(validProduct)
                
            }
            
        }
        
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("request failed")
        println(error)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for item in transactions {
            if let transaction = item as? SKPaymentTransaction {
                switch transaction.transactionState {
                    
                case .Purchased, .Restored:
                    removeAds()
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    break
                case .Failed:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                default:
                    break
                    
                }
            }
        }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        
        for item in queue.transactions {
            if let transaction = item as? SKPaymentTransaction {
                if transaction.transactionState == .Restored {
                    removeAds()
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    break
                }
            }
        }
        
        if queue.transactions.count == 0 {
            println("not restored")
            displayRestoreAlert()
        }
        
    }
    
    func displayRestoreAlert() {
        
        let alertController = UIAlertController(title: "Ad removal has not been purchased on this account.", message: nil, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func removeAds() {
        
        adBanner.hidden = true
        removeAdsButton.hidden = true
        moveAdBanner()
        adsRemoved = true
        
        // once purchase is complete, set NSUserDefaults
        NSUserDefaults.standardUserDefaults().setBool(adsRemoved, forKey: "adsRemoved")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }

}
