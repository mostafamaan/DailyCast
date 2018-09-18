//
//  SecondView.swift
//  DailyCast
//
//  Created by Mustafa on 2/19/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import UIKit

class SecondView: UIViewController,UITableViewDelegate,UITableViewDataSource,ElasticMenuTransitionDelegate {
    
    var transition = ElasticTransition()
    
    var lat:String!
    var time:String!
    var long:String!
    var timeMachine:TimeMachin!
    var hourlyTemp = [String]()
    var hourlyTime = [String]()
    var hourlyIcon = [String]()
    var hourlyWind = [String]()
    var hourlyHumidity = [String]()
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    var dismissByForegroundDrag = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var wind: UILabel!
    let lgr = UIScreenEdgePanGestureRecognizer()

    @IBOutlet weak var humidity: UILabel!
    
    override func viewDidLoad() {
        
        
        var contentLength:CGFloat = view.frame.height
        
        lgr.addTarget(self, action: "handlePan:")
        lgr.edges = .Left
        view.addGestureRecognizer(lgr)
        transition.edge = .Left
        transition.sticky = true
        transition.showShadow = false
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        
        
      //  let swipeRight = UISwipeGestureRecognizer(target: self, action: "segue:")
     //   swipeRight.direction = .Right
     //   view.addGestureRecognizer(swipeRight)
        let url = base_api + lat + "," + long + "," + time + "?lang=ar&units=si"
       // SwiftSpinner.show("Going to Future")
        timeMachine = TimeMachin(url: url)
        timeMachine.downloadWeatherDetails {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.tableView.backgroundColor = UIColor(red:0.06, green:0.11, blue:0.23, alpha:1.0)
            self.hourlyTemp = self.timeMachine._hourlyTemp
            self.hourlyTime = self.timeMachine._hourlyTime
            self.hourlyIcon = self.timeMachine._hourlyIcon
            self.hourlyWind = self.timeMachine._hourlyWind
            self.hourlyHumidity = self.timeMachine._hourlyHumidity
            self.view.backgroundColor = UIColor(red:0.35, green:0.82, blue:0.87, alpha:1.0)
            self.updateUI()
            print("time:",self.time)
            
        }
                
        
        
    }
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.dissmissInteractiveTransition(self, gestureRecognizer: pan, completion: nil)
            
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
  /*  func segue(sender:UISwipeGestureRecognizer) {
        
        if sender.direction == .Right {
    performSegueWithIdentifier("back", sender: self)
}
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = transition
        segue.destinationViewController.modalPresentationStyle = .Custom
        if segue.identifier == "back" {
            
        }
    }
    
    func updateUI() {
        tableView.reloadData()
        Loader.addLoaderTo(tableView)
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "loaded", userInfo: nil, repeats: false)
        summary.text = timeMachine.dailySummary
        temp.text = timeMachine.temp + "°"
        wind.text = timeMachine.wind
        humidity.text = timeMachine.humidity
        let icon = timeMachine.icon
        bigImageView.image = UIImage(contentsOfFile: makeImage(icon))
       // SwiftSpinner.hide()
        
        
        /////MARK PULL TO REFRESH
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.blackColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            
            self!.timeMachine.downloadWeatherDetails({ 
                self!.updateUI()
            })
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red:0.35, green:0.82, blue:0.87, alpha:1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        //////END MARK
        
    }
    
    func makeImage(ImageName:String) -> String {
        let path = NSBundle.mainBundle().pathForResource(ImageName, ofType: "png")
        return path!
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyTemp.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HuorlyCell
      
        cell.tempLabel.text = hourlyTemp[indexPath.row] + "°"
        cell.timeLabel.text = hourlyTime[indexPath.row]
        cell.hourlyWindLabel.text = hourlyWind[indexPath.row]
        cell.hourlyHumidity.text = hourlyHumidity[indexPath.row]
        cell.iconImageView.image = UIImage(contentsOfFile: makeImage(hourlyIcon[indexPath.row]))
        cell.backgroundColor = UIColor(red:0.06, green:0.11, blue:0.23, alpha:1.0)
        
        return cell
        
    }

    func loaded()
    {
        Loader.removeLoaderFrom(self.tableView)
        
    }
    //MARK:FIX SEGUE CRASH

    deinit {
        self.tableView.dg_removePullToRefresh()
    }
    
}
