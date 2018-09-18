//
//  ViewController.swift
//  DailyCast
//
//  Created by Mustafa on 2/15/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RMDateSelectionViewController
import JBChart
import NVActivityIndicatorView
import Foundation




class ViewController: UIViewController,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,JBLineChartViewDelegate,JBLineChartViewDataSource {
    
   
    var header = UILabel()
   
    var dailyDateNumberArray = [String]()
    var dailyDayArray = [String]()
    var dailyIconArray = [String]()
    var dailyMaxTempArray = [String]()
    var dailyMinTempArray = [String]()
    var topArray = [1]
    var bottomArray = ["1"]
    @IBOutlet weak var lineChart: JBLineChartView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let _headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let _tooltipView = TooltipView()
    let _tooltipTipView = TooltipTipView()
    
    var timeMachine:String!
    
    let locationManager = CLLocationManager()
    var LatitudeGPS = NSString()
    var LongitudeGPS = NSString()
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunSitLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    var weath:Weather!
    var lat:String!
    var lng:String!
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    
    
    let animation =  NVActivityIndicatorView(frame: CGRectMake(10.0, 0.0, 40.0, 40.0), type: .BallTrianglePath, color: UIColor.orangeColor() , size: CGSizeMake(100, 100) )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //cheak for gps
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                print("No access")
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Access")
            }
        } else {
            let aleart = UIAlertView(title: "Don't know where you are", message: "Location services are not enabled", delegate: self, cancelButtonTitle: "ok")
              aleart.show()
            
            
        }
        
        
        
        
        
        
        
        
        animation.center = view.center
        view.addSubview(animation)
        lgr.addTarget(self, action: "handlePan:")
        lgr.edges = .Left
        view.addGestureRecognizer(lgr)
        
        
      //  self.view.backgroundColor = UIColor(red:0.35, green:0.82, blue:0.87, alpha:1.0)
        
        //lineChart setup
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.reloadData()
        lineChart.setState(.Collapsed, animated: false)
        lineChart.backgroundColor = UIColor(red: 255/255, green: 226/255, blue: 225/255, alpha: 0)
        collectionView.layer.cornerRadius = 0.5
        collectionView.alpha = 0
       
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "openDateSelectionViewController")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
       
        
        summaryLabel.alpha = 0.0
       
        
        // Tooltip
        _tooltipView.alpha = 0.0
        lineChart.addSubview(_tooltipView)
        _tooltipTipView.alpha = 0.0
        lineChart.addSubview(_tooltipTipView)

        //header
        header = UILabel(frame: CGRectMake(0,0,lineChart.frame.width,50))
        header.textColor = UIColor.blackColor()
        header.font = UIFont.boldSystemFontOfSize(19)
        header.text = "Hourly cast"
        header.textAlignment = NSTextAlignment.Center
        lineChart.headerView = header
        
 
          MakeTvAnimation(windLabel, delay: 0)
          MakeTvAnimation(humidityLabel, delay: 0.2)
          MakeTvAnimation(sunRiseLabel, delay: 0.4)
          MakeTvAnimation(sunSitLabel, delay: 0.6)
          MakeTvAnimation(maxTempLabel, delay: 0.8)
          MakeTvAnimation(minTempLabel, delay: 1)
 
           updateLocation()
          lat = "\(LatitudeGPS)"
          lng = "\(LongitudeGPS)"
        
        

            weath = Weather(lat: lat, cityName: "iraq", long: lng)
            
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"downloadData", name:UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        
        
    }
    
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.edge = .Left
            transition.startInteractiveTransition(self, segueIdentifier: "showMenuSegue", gestureRecognizer: pan)
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }


    
    func updateUI() {
        
        let imageName = weath.icon
        let path = NSBundle.mainBundle().pathForResource(imageName, ofType: "png")
        bigImageView.image = UIImage(contentsOfFile: path!)
                

        UIView.animateWithDuration(4.0, animations: {
            //make it bigger
            self.bigImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
            
            }, completion: {(finished: Bool) -> Void in
                UIView.animateWithDuration(4.0, animations: {() -> Void in
                    //restore it to the original size
                    self.bigImageView.transform = CGAffineTransformMakeScale(1, 1)
                })
        })

        UIView.animateWithDuration(4, delay: 1, options: ([.CurveLinear]), animations: {
            self.summaryLabel.alpha = 1
            self.collectionView.alpha = 1
            }, completion: { _ in })
        
        summaryLabel.text = weath.summary
        cityNameLabel.text = weath.cityName
        windLabel.text = weath.wind + "Mps"
        humidityLabel.text = weath.humidity + "%"
        //making certen letters colored
        let string = weath.sunRise
        var sunRiseString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)])
        sunRiseString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:4,length:2))
        //end
        sunRiseLabel.attributedText = sunRiseString
        sunSitLabel.text = weath.sunSet
        currentWeatherLabel.text = weath.currentTemp + "°"
        maxTempLabel.text = String(format: "%.0f", weath.maxTemp) + "°"
        minTempLabel.text = String(format: "%.0f", weath.minTemp) + "°"
      
     //   Loader.removeLoaderFrom(collectionView)
        animation.stopAnimation()
        
      //  SwiftSpinner.hide()
    }
    
    //MARK: Location Manager
     func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        animation.startAnimation()
        //  SwiftSpinner.show("Getting your Weather")
        locationManager.stopUpdatingLocation() // Stop Location Manager - keep here to run just once
        
        LatitudeGPS = String(format: "%.6f", manager.location!.coordinate.latitude)
        LongitudeGPS = String(format: "%.6f", manager.location!.coordinate.longitude)
        
        downloadData()
        
        
       
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        
    }

    func updateLocation() {

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //self.locationManager.distanceFilter = 10
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
            
                    
        
    }


    func makeImage(ImageName:String) -> String {
        let path = NSBundle.mainBundle().pathForResource(ImageName, ofType: "png")
        return path!
    }
    
    func MakeTvAnimation(label:UILabel,delay:Double)
    {
        label.center = CGPointMake(self.view.bounds.size.width + label.bounds.size.width / 2, label.center.y)
        UIView.animateWithDuration(5, delay: delay, options: ([.CurveLinear]), animations: {() -> Void in
            label.center = CGPointMake(0 - label.bounds.size.width / 2, label.center.y)
            }, completion: { _ in })

    }
   
    func downloadData(){
        

        
        weath.makeWeatherUrl("\(LatitudeGPS)", long: "\(LongitudeGPS)")
        weath.downloadWeatherDetails {
            self.dailyDayArray = Array(self.weath._dailyDayArray.prefix(7))
            self.dailyIconArray = Array(self.weath._dailyIconArray.prefix(7))
            self.dailyDateNumberArray = Array(self.weath._dailyDateNumberArray.prefix(7))
            self.dailyMaxTempArray = Array(self.weath._dailyMaxTempArray.prefix(7))
            self.dailyMinTempArray = Array(self.weath._dailyMinTempArray.prefix(7))
            
            let min = self.topArray.minElement()! - 1
            let max = self.topArray.maxElement()! + 1
            
            self.lineChart.minimumValue = CGFloat(min)
            self.lineChart.maximumValue = CGFloat(max)
            
            
            self.topArray = Array(self.weath._hourlyTempArray.prefix(12))
            self.bottomArray = Array(self.weath._hourlyTimeArray.prefix(12))
            self.collectionView.reloadData()
            self.lineChart.reloadData()
            self.updateUI()
            self.setUsersClosestCity()
            

            
            
        }

    }
    
    // MARK: Time machine datepicker popup
    func openDateSelectionViewController() {
        let style = RMActionControllerStyle.White
        
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Cancel) { controller in
            if let dateController = controller as? RMDateSelectionViewController {
                
                self.timeMachine = String(format: "%.0f", dateController.datePicker.date.timeIntervalSince1970)
                                
                self.dismissViewControllerAnimated(false, completion: {
                    
                    self.performSegueWithIdentifier("segue", sender: self)
                })
                
                
            
            }
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { _ in
           
        }
        
        let actionController = RMDateSelectionViewController(style: style, title: "Time Machine", message: "This is a TimeMachine.\nPlease choose a date to get the weather for it :)", selectAction: selectAction, andCancelAction: cancelAction)!;
        
        
       
        
        //You can enable or disable blur, bouncing and motion effects
     //   actionController.disableBouncingEffects = !self.bouncingSwitch.on
      //  actionController.disableMotionEffects = !self.motionSwitch.on
      //  actionController.disableBlurEffects = !self.blurSwitch.on
        
        //You can access the actual UIDatePicker via the datePicker property
        actionController.datePicker.datePickerMode = .DateAndTime
        actionController.datePicker.minuteInterval = 5
        actionController.datePicker.date = NSDate(timeIntervalSinceNow: 0)
        
        //On the iPad we want to show the date selection view controller within a popover. Fortunately, we can use iOS 8 API for this! :)
        //(Of course only if we are running on iOS 8 or later)
        if actionController.respondsToSelector(Selector("popoverPresentationController:")) && UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            //First we set the modal presentation style to the popover style
            actionController.modalPresentationStyle = UIModalPresentationStyle.Popover
            
            //Then we tell the popover presentation controller, where the popover should appear
            if let popoverPresentationController = actionController.popoverPresentationController {
                popoverPresentationController.sourceView = summaryLabel
              //  popoverPresentationController.sourceRect = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            }
        }
        
        //Now just present the date selection controller using the standard iOS presentation method
        presentViewController(actionController, animated: true, completion: nil)
        
    }
    
    //MARK: prepareForSegue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .Custom
        
        if segue.identifier == "segue" {
            
        let secondVC = segue.destinationViewController as! SecondView
            
        secondVC.time = timeMachine
            secondVC.lat = "\(LatitudeGPS)"
            secondVC.long = "\(LongitudeGPS)"
        
    }
        else if segue.identifier == "collectionSegue" {
            transition.edge = .Left
            segue.destinationViewController.transitioningDelegate = transition
            segue.destinationViewController.modalPresentationStyle = .Custom
            
            let secondVc = segue.destinationViewController as! SecondView
            secondVc.time = weath.time
            secondVc.lat = "\(LatitudeGPS)"
            secondVc.long = "\(LongitudeGPS)"
        }
        }
    
        
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("collectionSegue", sender: self)
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyMinTempArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell2", forIndexPath: indexPath) as? HourlyCollectionCell
        
        
        cell?.dayLabel.text = dailyDayArray[indexPath.row]
        cell?.dayNumberLabel.text = dailyDateNumberArray[indexPath.row]
        cell?.dayImageView.image = UIImage(contentsOfFile: makeImage(self.dailyIconArray[indexPath.row]))
        cell?.maxTemp.text = dailyMaxTempArray[indexPath.row]  + "°"
        cell?.minTemp.text = dailyMinTempArray[indexPath.row] + "°"
        return cell!
        
        
    }
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lineChart.reloadData()
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "showChart", userInfo: nil, repeats: false)
        
        //MARK: footer
       /* let footerView = UIView(frame: CGRectMake(0,0,lineChart.frame.width,16) )
        let footer1 = UILabel(frame: CGRectMake(0,0,lineChart.bounds.width/2,16))
        footer1.textColor = UIColor.blackColor()
        footer1.text = String(bottomArray[0])
        footer1.font = UIFont.systemFontOfSize(12)
        let footer2 = UILabel(frame: CGRectMake(lineChart.bounds.width/2,0,lineChart.bounds.width/2,16))
        footer2.textColor = UIColor.blackColor()
        footer2.text = String(bottomArray[bottomArray.count - 1])
        footer2.textAlignment = NSTextAlignment.Right
        footer2.font = UIFont.systemFontOfSize(12)
        footerView.addSubview(footer1)
        footerView.addSubview(footer2)
        lineChart.footerView = footerView*/

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        hideChart()
    }

    
    func hideChart() {
        lineChart.setState(.Collapsed, animated: true)
    }
    
    func showChart() {
        lineChart.setState(.Expanded, animated: true)
    }
    
    //MARK: JBLinechartView
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if lineIndex == 0 {
            return UInt(bottomArray.count)
        }
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if lineIndex == 0 {
            return CGFloat(topArray[Int(horizontalIndex)])
        }
        
        return 0
          }
    
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if lineIndex == 0 {
             return UIColor.blackColor()
        }
        return UIColor.blackColor()
    }
    
    
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {
        if lineIndex == 0 {
            let data = String(topArray[Int(horizontalIndex)])
            // Adjust tooltip position
            var convertedTouchPoint:CGPoint = touchPoint
            let minChartX:CGFloat = (lineChart.frame.origin.x + ceil(_tooltipView.frame.size.width * 0.5))
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX
            }
            let maxChartX:CGFloat = (lineChart.frame.origin.x + lineChart.frame.size.width - ceil(_tooltipView.frame.size.width * 0.5))
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX
            }
            _tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(_tooltipView.frame.size.width * 0.5),
                                            CGRectGetMaxY(_headerView.frame),
                                            _tooltipView.frame.size.width,
                                            _tooltipView.frame.size.height)
            _tooltipView.setText(bottomArray[Int(horizontalIndex)] + "/" + data + "°" )
            
            
            var originalTouchPoint:CGPoint = touchPoint
            let minTipX:CGFloat = (lineChart.frame.origin.x + _tooltipTipView.frame.size.width)
            if (touchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX
            }
            let maxTipX = (lineChart.frame.origin.x + lineChart.frame.size.width - _tooltipTipView.frame.size.width)
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX
            }
            _tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(_tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(_tooltipView.frame), _tooltipTipView.frame.size.width, _tooltipTipView.frame.size.height)
            _tooltipView.alpha = 1.0
            _tooltipTipView.alpha = 1.0
            header.hidden = true
        
        }
        
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        _tooltipView.alpha = 0.0
        _tooltipTipView.alpha = 0.0
        header.hidden = false
    }


    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 3
    }

    func lineChartView(lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return JBLineChartViewLineStyle.Solid
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.orangeColor()
    }
    
    
    func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.blackColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return 4
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.brownColor()
    }
    

    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.blueColor()
    }
    
    func verticalSelectionWidthForLineChartView(lineChartView: JBLineChartView!) -> CGFloat {
        return 6
    }
    
    //MARK: get user address from lat and long
    func setUsersClosestCity()
    {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
           
            
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? NSString
            {
                
            }
            
            // Street address
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
            {
                
            }
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                
            }
            
            // state
            if let state  = placeMark.addressDictionary?["State"] as? NSString {
                
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
            {
                
            }
            
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? NSString
            {
                
            }
        }
    }
    
    
    
    
}
