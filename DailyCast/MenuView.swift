//
//  MenuView.swift
//  DailyCast
//
//  Created by Mustafa on 2/27/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import UIKit
import Alamofire
let documnet = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
let theCityNameArray = "/citiesFile1"
let theLocationArray = "/locations1"
let thePathToTheCity = documnet.stringByAppendingString(theCityNameArray)
let thePathToTheLocation = documnet.stringByAppendingString(theLocationArray)
let fileManager = NSFileManager.defaultManager()
var data = NSData()



class MenuView: UIViewController,UITableViewDelegate,UITableViewDataSource ,UITextFieldDelegate,ElasticMenuTransitionDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFiled: UITextField!
    let rgr = UIScreenEdgePanGestureRecognizer()
    
    var ltransition = ElasticTransition()
    var rtransition = ElasticTransition()
    
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    var dismissByForegroundDrag = true
    
    var cities = [String]()
    var citiesCordinits = [String]()
    var tempArray = [String]()
    var latitude:Double!
    var longtitude:Double!
    let cityName = "cityName"
    let cordinits = "location"
    let temp = "temp"
    var iconArray = [String]()
    
   
        var contentLength:CGFloat = 280
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "deleteCity:")
        longPress.minimumPressDuration = 2.0
        self.tableView.addGestureRecognizer(longPress)
        tableView.backgroundColor = UIColor.blueColor()
        
        
      //  var contentLength:CGFloat = view.frame.height
        tableView.delegate = self
        tableView.dataSource = self
        textFiled.delegate = self
        
        // customization
        ltransition.sticky = true
        rtransition.sticky = true
        ltransition.showShadow = false
        rtransition.showShadow = false
        ltransition.panThreshold = 0.3
        rtransition.panThreshold = 0.3
        ltransition.transformType = .TranslateMid
        rtransition.transformType = .TranslateMid
        // ...
        textFiled.backgroundColor = UIColor(red:0.85, green:0.86, blue:0.85, alpha:1.0)
        self.view.backgroundColor = UIColor(red:0.85, green:0.86, blue:0.85, alpha:1.0)
        tableView.backgroundColor = UIColor(red:0.85, green:0.86, blue:0.85, alpha:1.0)
        
        rgr.addTarget(self, action: "handlePan:")
        rgr.edges = .Right
        view.addGestureRecognizer(rgr)
        ltransition.edge = .Right
        rtransition.edge = .Left
        ltransition.sticky = true
        rtransition.sticky = true
        ltransition.showShadow = false
        rtransition.showShadow = false
        ltransition.panThreshold = 0.3
        rtransition.panThreshold = 0.3
        ltransition.transformType = .TranslateMid
        rtransition.transformType = .TranslateMid
        
    }
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            ltransition.dissmissInteractiveTransition(self, gestureRecognizer: pan, completion: nil)
            
        }else{
            ltransition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    
    
    
    //MARK: table view config
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("citiesCell") as? citiesCell
        
       cell?.backgroundColor = UIColor(red:0.85, green:0.86, blue:0.85, alpha:1.0)
        
    
        
         cell?.cityNameLabel.text = cities[indexPath.row]
        
        if tempArray.count < citiesCordinits.count {
          tableView.reloadData()
        }
         else {
          cell?.tempLabel.text = tempArray[indexPath.row] + "°"
            cell?.iconImageView.image = UIImage(contentsOfFile: makeImage(self.iconArray[indexPath.row]))
          
         }
        
        
        return cell!
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("citySegue", sender: self)
        
        
    }
    
   
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("Menu: viewDidAppear")
        let cityNameData = NSData(contentsOfFile: thePathToTheCity)
        if cityNameData != nil {
            self.cities = NSKeyedUnarchiver.unarchiveObjectWithData(cityNameData!) as! [String]
        }
        
        let locationData = NSData(contentsOfFile: thePathToTheLocation)
        if locationData != nil {
            self.citiesCordinits = NSKeyedUnarchiver.unarchiveObjectWithData(locationData!) as! [String]
            
            
        }
        getWeather {
            self.tableView.reloadData()
        }
        
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        downloadCity {
            self.tableView.reloadData()
        }
        
        
        
        
        textField.resignFirstResponder()
        
        
        
        return true
    }
    
    
    
    
    
    func getWeather (completed: DownloadComplete) {
        //  tableView.reloadData()
        
        for i in 0 ..< citiesCordinits.count {
            let url = base_api + citiesCordinits[i] + "?lang=ar&units=si"
            Alamofire.request(Method.GET, url).responseJSON { response in
                let result = response.result
                
                if let dict = result.value as? Dictionary<String,AnyObject> {
                    if let currently = dict["currently"] as? Dictionary<String,AnyObject> {
                        if let temp = currently["temperature"] as? Double {
                            let str = String(format: "%.0f", temp)
                            self.tempArray.append("\(str)")
                            
                            
                            
                        }
                        if let icon = currently["icon"] as? String {
                            self.iconArray.append(icon)
                            
                        }
                    }
                    
                    
                    
                }
            }
            
            completed()
        }
        // tableView.reloadData()
        
        
    }


    //MARK:getting city lang and lat
    func downloadCity(completed: DownloadComplete){
        let urlBefore = googleApi
        let url = urlBefore.stringByReplacingOccurrencesOfString("mosul", withString: textFiled.text!.stringByReplacingOccurrencesOfString(" ", withString: ""))
        Alamofire.request(Method.GET, url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String,AnyObject> {
                if let status = dict["status"] as? String {
                    if status == "OK" {
                        if let result = dict["results"] as? [Dictionary<String,AnyObject>] {
                            if let geometry = result[0]["geometry"] as? Dictionary<String,AnyObject> {
                                if let location = geometry["location"] as? Dictionary<String,Double> {
                                    if let lat = location["lat"] {
                                        self.latitude = lat
                                        print(self.latitude)
                                        
                                    }
                                    
                                    if let lng = location["lng"] {
                                        self.longtitude = lng
                                        print(self.longtitude)
                                    }
                                    
                                    
                                    self.cities.append(self.textFiled.text!)
                                    self.citiesCordinits.append("\(self.latitude),\(self.longtitude)")
                                    print(self.citiesCordinits)
                                    
                                    
                                    
                                    let mycities = NSKeyedArchiver.archivedDataWithRootObject(self.cities)
                                    mycities.writeToFile(thePathToTheCity, atomically: true)
                                    let myLocations = NSKeyedArchiver.archivedDataWithRootObject(self.citiesCordinits)
                                    myLocations.writeToFile(thePathToTheLocation, atomically: true)
                                    
                                    
                                    self.getWeather({
                                        
                                    })
                                    
                                    
                                    
                                }
                            }
                            
                            
                            
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
            completed()
        }
        
        
        
        
        
    }
    //END MARK
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = rtransition
        segue.destinationViewController.modalPresentationStyle = .Custom

        if segue.identifier == "citySegue" {
            let dsvc = segue.destinationViewController as! CityViewController
            let selectedRow = tableView.indexPathForSelectedRow!.row
                dsvc.location = citiesCordinits[selectedRow]
            dsvc.cityName = cities[selectedRow]
            dsvc.bibImage = iconArray[selectedRow]
            
            
        }
        
        if segue.identifier == "backToViewController" {
            
        }
    }

    func deleteCity(sender:UILongPressGestureRecognizer) {
        let longPress: UILongPressGestureRecognizer = sender
        let state: UIGestureRecognizerState = longPress.state
        let location: CGPoint = longPress.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(location)!
    cities.removeAtIndex(indexPath.row)
    citiesCordinits.removeAtIndex(indexPath.row)
    tempArray.removeAtIndex(indexPath.row)
        iconArray.removeAtIndex(indexPath.row)
    let mycities = NSKeyedArchiver.archivedDataWithRootObject(self.cities)
    mycities.writeToFile(thePathToTheCity, atomically: true)
    let myLocations = NSKeyedArchiver.archivedDataWithRootObject(self.citiesCordinits)
    myLocations.writeToFile(thePathToTheLocation, atomically: true)
    tableView.reloadData()
}
    
    func makeImage(ImageName:String) -> String {
        let path = NSBundle.mainBundle().pathForResource(ImageName, ofType: "png")
        return path!
    }



    
}
