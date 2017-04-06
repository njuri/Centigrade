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
//  @IBOutlet weak var descriptionLabel: UILabel!
//  @IBOutlet weak var placeLabel: UILabel!
//  @IBOutlet weak var loadingInidcator: UIActivityIndicatorView!
  
  let locationManager = CentigradeLocationManager()
  let cardStackController = CardStackController()

  
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
    
//    loadingInidcator.startAnimating()
//
//    if locationManager.isAuthorized{
//      locationManager.requestCurrentLocation()
//    }else{
//      locationManager.requestPermission()
//    }
//    
  }
  
  @IBAction func profilePressed(_ sender: Any) {
    cardStackController.delegate = self
    present(cardStackController, animated: false, completion: nil)
    let profileCardController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
    profileCardController.delegate = self
    UIApplication.shared.statusBarStyle = .lightContent
    cardStackController.stack(viewController: profileCardController)
  }
  
  func sendWeatherRequest(with coordinate : CLLocationCoordinate2D){
    APIClient.requestForecast(for: coordinate) { (dataPoint, error) in
     // self.loadingInidcator.stopAnimating()
      guard error == nil else {
        self.updateLabels(with: nil)
        return
      }
      self.updateLabels(with: dataPoint)
    }
  }
  
  func updateLabels(with dataPoint : WeatherDataPoint?){
    guard let dataPoint = dataPoint else{
      degreeLabel.text = "-"
   //   descriptionLabel.text = "-"
      return
    }
    degreeLabel.text = dataPoint.displayTemperature
   // descriptionLabel.text = dataPoint.readableSummary
  }
  
  func updatePlace(with name : String?){
//    if let name = name{
//      placeLabel.text = name
//    }else{
//      placeLabel.text = "–"
//    }
  }
  
  
}

extension WeatherDisplayViewController : LocationManagerDelegate{
  func didFailToReceiveLocation() {
    updatePlace(with: nil)
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
      self.updatePlace(with: locality)
    }
  }
}

extension WeatherDisplayViewController : CardStackControllerDelegate, ProfileCardControllerDelegate{
  func didFinishDismissingCardController() {
    UIApplication.shared.statusBarStyle = .default
  }
  
  func dismissPressed() {
    cardStackController.unstackLastViewController()
  }
}
