//
//  CityViewController.swift
//  DailyCast
//
//  Created by Mustafa on 2/26/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//

import UIKit
import Alamofire

class CityViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,ElasticMenuTransitionDelegate {
    
    
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    var dismissByForegroundDrag = true    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var location:String!
    var cityName:String!
    var weath:CityWeather!
    var tempArray = [String]()
    var iconArray = [String]()
    var dayArray = [String]()
    var bibImage:String!
    
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        cityNameLabel.text = cityName.capitalizedString
        iconImageView.image = UIImage(contentsOfFile: makeImage(bibImage))
        collectionView.backgroundColor = UIColor.clearColor()
        var contentLength:CGFloat = view.frame.height
        lgr.addTarget(self, action: "handlePan:")
        lgr.edges = .Right
        view.addGestureRecognizer(lgr)
        transition.edge = .Right
        transition.sticky = true
        transition.showShadow = false
        transition.panThreshold = 0.3
        transition.transformType = .TranslateMid
        
    weath = CityWeather(location: location)
        weath.downloadWeatherDetails { 
            self.updateUI()
        }
    
    }
    
    func handlePan(pan:UIPanGestureRecognizer){
        if pan.state == .Began{
            transition.dissmissInteractiveTransition(self, gestureRecognizer: pan, completion: nil)
            
        }else{
            transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = transition
        segue.destinationViewController.modalPresentationStyle = .Custom
        if segue.identifier == "backToMenu" {
            
        }
    }
    
    func updateUI() {
        tempLabel.text = String(format: "%.0f", weath.temp) + "°"
        windLabel.text = "\(weath.wind)Mph"
        humidityLabel.text = String(format: "%.0f", weath.humidity) + "%"
        tempArray = weath._tempArray
        iconArray = weath._iconArray
        dayArray = weath._dayArray
        // timeLabel.text = weath.time
        
        collectionView.reloadData()
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return tempArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? CityCell
        
        if indexPath.row % 2 == 0 {
            cell?.backgroundColor = UIColor(red:0.73, green:0.46, blue:0.69, alpha:0.5)
            
        }
        else {
            cell?.backgroundColor = UIColor(red:0.85, green:0.66, blue:0.81, alpha:1.0)
        }

       cell?.backgroundColor = UIColor.clearColor()
        cell?.timeLabel.text = dayArray[indexPath.row]
        cell?.tempLabel.text = tempArray[indexPath.row]
        cell?.iconImageView.image = UIImage(contentsOfFile: makeImage(iconArray[indexPath.row]))
        
        
        return cell!
    }
    
    func makeImage(ImageName:String) -> String {
        let path = NSBundle.mainBundle().pathForResource(ImageName, ofType: "png")
        return path!
    }


}
