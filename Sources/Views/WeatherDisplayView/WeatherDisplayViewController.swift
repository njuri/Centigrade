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
  
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var degreeLabel: TemperatureDisplayLabel!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var locationBackgroundView: UIView!
  @IBOutlet weak var locationIcon: UIImageView!
  @IBOutlet weak var currentWeatherIcon: UIImageView!
  @IBOutlet weak var currentWeatherSummaryLabel: UILabel!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  
  let locationManager = CentigradeLocationManager()
  let cardStackController = CardStackController()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    setupLocationView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateUserProfile()
    loadCurrentWeather()
  }
  
  func setupLocationView(){
    locationBackgroundView.layer.cornerRadius = 5
    locationIcon.image = locationIcon.image?.withRenderingMode(.alwaysTemplate)
    locationIcon.tintColor = placeLabel.textColor
  }
  
  func updateUserProfile(){
    guard let imageData = CoreDataFactory.user.imageData else {
      userProfileImageView.image = #imageLiteral(resourceName: "user")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let image = UIImage(data: imageData as Data)
      DispatchQueue.main.async {
        self.userProfileImageView.image = image
      }
    }

  }
  
  func loadCurrentWeather(){
    guard UserSettings.canUpdateWeather else { return }
    print("Starting weather update")
    loadingIndicator.startAnimating()

    if locationManager.isAuthorized{
      locationManager.requestCurrentLocation()
    }else{
      locationManager.requestPermission()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height/2
    userProfileImageView.layer.borderWidth = 1
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
    APIClient.requestCurrentForecast(for: coordinate) { (dataPoint, error) in
     self.loadingIndicator.stopAnimating()
      guard error == nil else {
        self.updateLabels(with: nil)
        return
      }
      UserSettings.didUpdateWeather()
      self.updateLabels(with: dataPoint)
      if let dataPoint = dataPoint{
        _ = CoreDataFactory.saveDataPoint(dataPoint: dataPoint)
      }
    }
  }
  
  func updateLabels(with dataPoint : WeatherDataPoint?){
    guard let dataPoint = dataPoint else{
      degreeLabel.text = "-"
      currentWeatherSummaryLabel.text = "-"
      return
    }
    degreeLabel.set(to: dataPoint.temperature)
    currentWeatherSummaryLabel.text = dataPoint.readableSummary
    currentWeatherIcon.image = dataPoint.summary.icon
  }
  
  func updatePlace(with name : String?){
    if let name = name{
      placeLabel.text = name
    }else{
      placeLabel.text = "–"
    }
    placeLabel.sizeToFit()
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
    UserSettings.currentLocation = location.coordinate
    sendWeatherRequest(with: location.coordinate)
    locationManager.placemarkLocality(from: location) { locality in
      self.updatePlace(with: locality)
    }
  }
}

extension WeatherDisplayViewController : CardStackControllerDelegate, ProfileCardControllerDelegate{
  func didFinishDismissingCardController() {
    UIApplication.shared.statusBarStyle = .default
    // Save profile
    CoreDataFactory.save()
  }
  
  func dismissPressed() {
    cardStackController.unstackLastViewController()
  }
}
