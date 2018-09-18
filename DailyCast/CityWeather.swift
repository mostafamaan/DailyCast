//
//  CityWeather.swift
//  DailyCast
//
//  Created by Mustafa on 2/26/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import Foundation
import Alamofire

class CityWeather {
    
    private var _temp:Double!
    private var _humidity:Double!
    private var _wind:Double!
    var location:String!
    var _dayArray = [String]()
    var _tempArray = [String]()
    var _iconArray = [String]()
    private var _time:String!
    
    
    var time:String {
        get {
            return _time
        }
    }
    
    var temp:Double {
        get {
            return _temp
        }
    }
    
    var humidity:Double {
        get {
            return _humidity
        }
    }
    
    var wind:Double {
        get {
            return _wind
        }
    }
    
    init(location:String) {
        self.location = location
        
    }
    
    func downloadWeatherDetails(completed: done){
        
        
        
        
        Alamofire.request(Method.GET, base_api + location + "?lang=ar&units=si" ).responseJSON { response in
            let result = response.result
            
            //convert the json into dictionary
            if let dict = result.value as? Dictionary<String,AnyObject> {
                
                if let daily = dict["daily"] as? Dictionary<String,AnyObject> {
                    if let data = daily["data"] as? [Dictionary<String,AnyObject>] {
                        for i in 0 ..< data.count {
                          if let time = data[i]["time"] as? Double {
                            
                            let day = self.prossesTimeFull(time)
                            let dayString = self.getDayOfWeekString(day)
                            self._dayArray.append(dayString!)
                            
                            }
                            
                            if let icon = data[i]["icon"] as? String {
                                self._iconArray.append(icon)
                                
                            }
                            
                            if let temp = data[i]["temperatureMax"] as? Double {
                                let str = String(format: "%.0f", temp)
                                self._tempArray.append(str)
                                
                            }
                            
                        }
                    }
                }
                
                
                if let currently = dict["currently"] as? Dictionary<String,AnyObject> {
                    if let temp = currently["temperature"] as? Double {
                        self._temp = temp
                        print(self._temp)
                    }
                    
                    if let wind = currently["windSpeed"] as? Double {
                        self._wind = wind
                        print(self._wind)
                    }
                    
                    if let humidity = currently["humidity"] as? Double {
                        self._humidity = humidity
                        print(self._humidity)
                    }
                    
                    if let time = currently["time"] as? Double {
                        let day = self.prossesTimeFull(time)
                        self._time = day
                        
                    }
                }
                
            }
            
            completed()
        }
        
    }
    
    func prossesTimeFull(currentDay:Double) -> String {
        let date = NSDate(timeIntervalSince1970: currentDay)
        let timeFormatter = NSDateFormatter()
        
        timeFormatter.dateFormat = "yyyy-MM-dd"
        
        let day = timeFormatter.stringFromDate(date)
        
        return day
    }

    
    func getDayOfWeekString(today:String)->String? {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
            let weekDay = myComponents.weekday
            switch weekDay {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                
                return "Day"
            }
        } else {
            return nil
        }
    }


    
    
}