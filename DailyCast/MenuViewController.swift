//
//  MenuViewController.swift
//  DailyCast
//
//  Created by Mustafa on 2/25/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import UIKit
import Alamofire
/*let documnet = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
let theCityNameArray = "/citiesFile1"
let theLocationArray = "/locations1"
let thePathToTheCity = documnet.stringByAppendingString(theCityNameArray)
let thePathToTheLocation = documnet.stringByAppendingString(theLocationArray)
let fileManager = NSFileManager.defaultManager()
var data = NSData()*/

/*


class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UITextFieldDelegate,ElasticMenuTransitionDelegate {
    
    var transition = ElasticTransition()
    
    
    
    var cities = [String]()
    var citiesCordinits = [String]()
    var tempArray = [String]()
    var latitude:Double!
    var longtitude:Double!
    let cityName = "cityName"
    let cordinits = "location"
    let temp = "temp"
    var iconArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
               
        // customization
        transition.edge = .Right
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        // ...
        

        
        
        
      
     //   self.textField.backgroundColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor(red:0.35, green:0.82, blue:0.87, alpha:1.0)
        
  
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Menu: viewWillAppear")
       
        

        
        
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
            
        }

        
        
    }
    
      
    
    
    func downloadCity(completed: DownloadComplete){
     let urlBefore = googleApi
        let url = urlBefore.stringByReplacingOccurrencesOfString("mosul", withString: textField.text!.stringByReplacingOccurrencesOfString(" ", withString: ""))
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
                        
                        
                        self.cities.append(self.textField.text!)
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
   }
        
        completed()
    
    
    
    
}
   
    //MARK: table view config
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
           // cities.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("citiesCell") as? citiesCell
        
      //  cell?.cityNameLabel.text = cities[indexPath.row]
        //if tempArray.count < citiesCordinits.count {
          //  tableView.reloadData()
        //}
       // else {
         //   cell?.tempLabel.text = tempArray[indexPath.row]
       // }
        
        
        return cell!
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("citySegue", sender: self)

        
    }
    
    
    //END MARK
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        downloadCity {
            
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
                            self.tempArray.append("\(temp)")
                            print("tempArray",self.tempArray)
                            
                            
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
    
 /*   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
               
        if segue.identifier == "citySegue" {
            let dsvc = segue.destinationViewController as! CityViewController
            let selectedRow = //tableView.indexPathForSelectedRow!.row
            dsvc.location = citiesCordinits[selectedRow]
            dsvc.cityName = cities[selectedRow]
            dsvc.bibImage = iconArray[selectedRow]
            
            
        }
    }*/
    
  
}*/


