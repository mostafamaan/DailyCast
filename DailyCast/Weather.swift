//
//  Weather.swift
//  DailyCast
//
//  Created by Mustafa on 2/15/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import Foundation
import Alamofire
let dateComponents = NSDateComponents()
let day = dateComponents.day
let month = dateComponents.month
let currentDate = NSDate()
let dateFormatter = NSDateFormatter()
let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)

extension Array {
    func takeElements(var elementCount: Int) -> Array {
        if (elementCount > count) {
            elementCount = count
        }
        return Array(self[0..<elementCount])
    }
}


extension NSDate
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
}

class Weather {
    
    var _dailyDateNumberArray = [String]()
    var _dailyDayArray = [String]()
    var _dailyIconArray = [String]()
    var _dailyMaxTempArray = [String]()
    var _dailyMinTempArray = [String]()
    var _hourlyTimeArray = [String]()
    var _hourlyTempArray = [Int]()
    private var _summary:String!
    private var _location:String!
    private var _cityName:String!
    private var _wind:String!
    private var _humidity:String!
    private var _sunRise:String!
    private var _sunSit:String!
    private var _moonRise:String!
    private var _moonSit:String!
    private var _currentTemp:String!
   
    private var _currentTempTime:String!
    private var _weatherUrl:String!
    private var _icon:String!
    
    private var _minTemp:Double!
    private var _maxTemp:Double!
    private var _latitude:String!
    private var _longitude:String!
    private var _time:String!
        
    
    var time:String {
        get {
            return _time
        }
    }
    
    
    var latitude:String {
        get {
            return _latitude
        }
    }
    
    var longitude:String {
        get {
            return _longitude
        }
    }
    
    
    var icon:String {
        get {
            return _icon
        }
    }
    
    var minTemp:Double {
        get {
            return _minTemp
        }
    }
    
    var maxTemp:Double {
        get {
            return _maxTemp
        }
    }
    
    var location:String {
        
        return _location
        
    }
    
    var cityName:String {
        
        if _cityName == nil {
            _cityName = ""
        }
        
        return _cityName
        
    }
    
    var wind:String {
        get {
            return _wind
        }
    }
    
    var humidity:String {
        get {
            return _humidity
        }
    }
    
    var sunRise:String {
        get {
            return _sunRise
        }
    }
    
    var sunSet:String {
        get {
            return _sunSit
        }
    }
    
    var moonRise:String {
        get {
            return _moonSit
        }
    }
    
    var moonSit:String {
        get {
            return _moonSit
        }
    }
    
    var currentTemp:String {
        get {
            return _currentTemp
        }
    }
    
      
    var currentTempTime:String {
        get {
            return _currentTempTime
        }
    }
    
    var summary:String {
        get {
            return _summary
        }
    }
    
    init(lat:String,cityName:String,long:String){
        self._latitude = lat
        self._longitude = long
        
        
        
    }
    
    func downloadWeatherDetails(completed: DownloadComplete){
        
        
        
        
        Alamofire.request(Method.GET, _weatherUrl).responseJSON { response in
            let result = response.result
            
            //convert the json into dictionary
            if let dict = result.value as? Dictionary<String,AnyObject> {
                
                
                if let hourly = dict["hourly"] as? Dictionary<String,AnyObject> {
                    if let data = hourly["data"] as? [Dictionary<String,AnyObject>] {
                        
                        for i in 0 ..< data.count {
                            if let time = data[i]["time"] as? Double {
                                let date = NSDate(timeIntervalSince1970: time)
                                let timeFormatter = NSDateFormatter()
                                timeFormatter.dateFormat = "h:a"
                                self._hourlyTimeArray.append(timeFormatter.stringFromDate(date))
                                
                            }
                            
                            if let temp = data[i]["temperature"] as? Double {
                                
                                let tempInt = Int(temp)
                                self._hourlyTempArray.append(tempInt)
                            
                            }
                            
                            
                        }
                    }
                }
                
                
                
                if let daily = dict["daily"] as? Dictionary<String,AnyObject> {
                    
                    
                   if let data = daily["data"] as? [Dictionary<String,AnyObject>] {
                        
                    for i in 0 ..< data.count  {
                            if let sunRise = data[0]["sunriseTime"] as? Double {
                                let date = NSDate(timeIntervalSince1970: sunRise)
                                let timeFormatter = NSDateFormatter()
                                timeFormatter.dateFormat = "h:mma"
                                self._sunRise = timeFormatter.stringFromDate(date)
                                
                            }
                        
                            
                            
                            if let sunSit = data[0]["sunsetTime"] as? Double {
                                let date = NSDate(timeIntervalSince1970: sunSit)
                                let timeFormatter = NSDateFormatter()
                                timeFormatter.dateFormat = "h:mma"
                                self._sunSit = timeFormatter.stringFromDate(date)
                                
                            }
                            
                            
                            if let mintemp = data[0]["temperatureMin"] as? Double {
                                
                                
                                self._minTemp = mintemp
                                
                            }
                            if let maxtemp = data[0]["temperatureMax"] as? Double {
                                
                                
                                self._maxTemp = maxtemp
                            }


                        
                                               
                        
                            
                            if let time = data[i]["time"] as? Double {
                                let dayNumber = self.prossesTimeDay(time)
                                self._dailyDateNumberArray.append(dayNumber)
                                let day = self.prossesTimeFull(time)
                                let dayString = self.getDayOfWeekString(day)
                                self._dailyDayArray.append(dayString!)
                                self._time = String(format: "%.0f", time)
                                
                                
                                
                            }
                            
                            if let icon = data[i]["icon"] as? String {
                                self._dailyIconArray.append(icon)
                                
                            }
                            
                            if let maxTemp = data[i]["temperatureMax"] as? Double {
                            
                                let maxString = String(format: "%.0f", maxTemp)
                                self._dailyMaxTempArray.append(maxString)
                                
                            }
                            
                            if let minTemp = data[i]["temperatureMin"] as? Double {
                               
                                let minString = String(format: "%.0f", minTemp)
                                self._dailyMinTempArray.append(minString)
                                
                            }
                        }
                        
                    }

                }
                
                
                
                
                
                if let hourly = dict["hourly"] as? Dictionary<String,AnyObject> {
                    if let summary = hourly["summary"] as? String {
                        self._summary = summary
                        
                    }
                }
                
                
                
                
                if let currentWeather = dict["currently"] as? Dictionary<String,AnyObject> {
                    
                    if let icon = currentWeather["icon"] as? String
                    {
                     self._icon = icon
                       
                    }
                    
                    if let temp = currentWeather["temperature"] as? Double {
                        
                        self._currentTemp = String(format:"%.0f", temp)
                                           }
                    if let humidity = currentWeather["humidity"] as? Double
                    {
                        let HString = "\(humidity)"
                        self._humidity = HString.stringByReplacingOccurrencesOfString("0.", withString: "")
                        
                        
                        
                    }
                    
                    if let wind = currentWeather["windSpeed"] as? Double {
                        
                        self._wind = String(format: "%.1f", wind)
                        
                        
                    }
                    
                    if let summary = currentWeather["summary"] as? String {
                        self._cityName = summary
                        
                    }
                    
                    
                    
                }
                completed()
                
                
                
            }
                    
           
            
        }
        
        
    }
    
    
    func endOfTheMonth() -> String {
        
        let date2 = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month], fromDate: date2)
        let startOfMonth = calendar.dateFromComponents(components)!
        let comps2 = NSDateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = calendar.dateByAddingComponents(comps2, toDate: startOfMonth, options: [])!
        return dateFormatter.stringFromDate(endOfMonth)
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
    
    func prossesTimeFull(currentDay:Double) -> String {
        let date = NSDate(timeIntervalSince1970: currentDay)
        let timeFormatter = NSDateFormatter()
        
        timeFormatter.dateFormat = "yyyy-MM-dd"
        
        let day = timeFormatter.stringFromDate(date)
        
        return day
    }
    func prossesTimeDay(currentDay:Double) -> String {
        let date = NSDate(timeIntervalSince1970: currentDay)
        let timeFormatter3 = NSDateFormatter()
        timeFormatter3.dateFormat = "dd"
        let dayNumber = timeFormatter3.stringFromDate(date)
        
        return dayNumber
        
        
    }
    
    func prossesTimeHour(currentDay:Double) -> String {
        let date = NSDate(timeIntervalSince1970: currentDay)
        let timeFormatter2 = NSDateFormatter()
        timeFormatter2.dateFormat = "ha"
        let time = timeFormatter2.stringFromDate(date)
        
        return time
        
        
        
        
    }
    
    
    func makeWeatherUrl(lat:String,long:String) {
        let weatherUrl = "\(base_api)\(lat),\(long)?lang=en&units=si"
        self._weatherUrl = weatherUrl
        
    
   }
    
    func convertToDgree(temp:Double) -> Double {
        
        let double = (temp - 32) * 5/9
        return double
        
    }
}
