//
//  WeatherDisplayViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 31.03.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CoreLocation
import CentigradeKit

final class WeatherDisplayViewController: UIViewController {

  @IBOutlet weak var degreeLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var loadingInidcator: UIActivityIndicatorView!
  
  let locationManager = CentigradeLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadCurrentWeather()
  }
  
  func loadCurrentWeather(){
    
    loadingInidcator.startAnimating()

    if locationManager.isAuthorized{
      locationManager.requestCurrentLocation()
    }else{
      locationManager.requestPermission()
    }
    
  }
  
  func sendWeatherRequest(with coordinate : CLLocationCoordinate2D){
    APIClient.requestForecast(for: coordinate) { (dataPoint, error) in
      guard error == nil else {
        self.degreeLabel.text = "-"

        return
      }
      guard let dataPoint = dataPoint else {
        self.degreeLabel.text = "-"
        return
      }
      
      self.degreeLabel.text = dataPoint.displayTemperature
    }
  }
  
  
}

extension WeatherDisplayViewController : LocationManagerDelegate{
  func didFailToReceiveLocation() {
    self.placeLabel.text = "-"
  }
  
  func didUpdateLocationAuthorizationStatus() {
    guard locationManager.isAuthorized else {
      self.degreeLabel.text = "-"
      return
    }
    locationManager.requestCurrentLocation()
  }
  
  func didReceive(location: CLLocation) {
    sendWeatherRequest(with: location.coordinate)
    locationManager.placemarkLocality(from: location) { locality in
      print("Recognized locality")
      guard let locality = locality else {
        self.placeLabel.text = "-"
        return
      }
     self.placeLabel.text = locality
    }
  }
}
