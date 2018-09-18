//
//  TimeMachine.swift
//  DailyCast
//
//  Created by Mustafa on 2/19/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import Foundation
import Alamofire

class TimeMachin {
    
    private var _humidity:String!
    private var _temp:String!
    private var _wind:String!
    private var _url:String!
    private var _icon:String!
    var _hourlyTime = [String]()
     var _hourlyTemp = [String]()
     var _hourlyIcon = [String]()
     var _hourlyWind = [String]()
     var _hourlyHumidity = [String]()
    private var _dailySummary:String!
    
    
    var dailySummary:String {
        get {
            return _dailySummary
        }
    }
    
    
    
    var humidity:String {
        get {
            return _humidity
        }
    }
    
    var temp:String {
        get {
            return _temp
        }
    }
    
    var wind:String {
        get {
            return _wind
        }
    }
    
    var url:String {
        get {
            return _url
        }
    }
    
    var icon:String {
        get {
            return _icon
        }
    }
   
    init(url:String) {
        self._url = url
    }
    
    
    func downloadWeatherDetails(completed: DownloadComplete){
        
        Alamofire.request(Method.GET, _url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String,AnyObject> {
                
                if let daily = dict["daily"] as? Dictionary<String,AnyObject> {
                    if let data = daily["data"] as? [Dictionary<String,AnyObject>] {
                        
                        
                            
                            if let summary = data[0]["summary"] as? String {
                                self._dailySummary = summary
                            

                            
                        }
                        
                        
                        
                    }
                }
                
                
                
                if let currently = dict["currently"] as? Dictionary<String,AnyObject> {
                    
                    
                    if let icon = currently["icon"] as? String {
                        self._icon = icon
                        print(self._icon)
                    }
                    
                    if let temp = currently["temperature"] as? Double {
                        
                        self._temp = String(format: "%.1f", temp)
                        print(self._temp)
                    }
                    
                    if let wind = currently["windSpeed"] as? Double {
                        
                        self._wind = String(format: "%.1f", wind) + "Mps"
                        
                    }
                    
                    if let humidity = currently["humidity"] as? Double {
                        let h = "\(humidity)"  + "%"
                        self._humidity = h.stringByReplacingOccurrencesOfString("0.", withString: "")
                        
                    }
                }
                
                if let hourly = dict["hourly"] as? Dictionary<String,AnyObject> {
                    if let data = hourly["data"] as? [Dictionary<String,AnyObject>] {
                        for i in 0 ..< data.count {
                            if let temp = data[i]["temperature"] as? Double {
                                
                                let tempString = String(format: "%.0f", temp)
                                self._hourlyTemp.append(tempString)
                                
                            }
                            
                            if let time = data[i]["time"] as? Double {
                                let date = NSDate(timeIntervalSince1970: time)
                                let timeFormatter2 = NSDateFormatter()
                                timeFormatter2.dateFormat = "ha"
                                let timeString = timeFormatter2.stringFromDate(date)
                                
                                self._hourlyTime.append(timeString)
                                
                            }
                            
                            if let icon = data[i]["icon"] as? String {
                                self._hourlyIcon.append(icon)
                                
                            }
                            
                            if let wind = data[i]["windSpeed"] as? Double {
                                
                                let windString = String(format: "%.1f", wind) + "Mps"
                                self._hourlyWind.append(windString)
                            }
                            
                            if let humidity = data[i]["humidity"] as? Double {
                                let h = "\(humidity)%"
                                let string = h.stringByReplacingOccurrencesOfString("0.", withString: "")
                                self._hourlyHumidity.append(string)
                            }
                            
                            

                            
                        }
                        
                    }
                }
                
            }
            

        
        completed()
    }
    
    }
    
    func convertToDgree(temp:Double) -> Double {
        
        let double = (temp - 32) * 5/9
        return double
        
    }

    
    
}