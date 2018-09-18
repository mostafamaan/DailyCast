//
//  Api.swift
//  DailyCast
//
//  Created by Mustafa on 2/15/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import Foundation
let base_api = "https://api.forecast.io/forecast/1a545ca50e76c73f9f89efa13aee2d7e/"
//var base_url = "http://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=c04dd12c7bb3a475dc9b0625d8761df6"
var _base_url = "http://api.openweathermap.org/data/2.5/weather?q=mosul&units=metric&appid=c04dd12c7bb3a475dc9b0625d8761df6"
var image_Url = "http://openweathermap.org/img/w/10d.png"
var api = "c04dd12c7bb3a475dc9b0625d8761df6"
var googleApi = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=@%22mosul%22"
// 36.8679050,42.9488570

// https://api.forecast.io/forecast/1a545ca50e76c73f9f89efa13aee2d7e/36.8679050,42.9488570?units=si&lang=ar
typealias DownloadComplete = () -> ()
typealias done = () -> ()

