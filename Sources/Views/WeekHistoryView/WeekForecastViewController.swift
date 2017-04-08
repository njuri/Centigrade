//
//  WeekForecastViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 07.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CoreLocation
import CentigradeKit

final class WeekForecastViewController: UIViewController {
  
  @IBOutlet weak var historyTableView: UITableView!
  
  var historyDataPoints : [WeatherDataPoint] = []{
    didSet{
      DispatchQueue.main.async {
        self.historyTableView.reloadData()
      }
    }
  }
  
  var currentLocation : CLLocationCoordinate2D? = UserSettings.currentLocation{
    didSet{
      loadCurrentWeather()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    historyTableView.register(UINib(nibName: WeekForecastViewCell.classString(), bundle:nil), forCellReuseIdentifier: WeekForecastViewCell.classString())
    NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: CentigradeNotification.locationDidChange.notification, object: nil)
    //historyTableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadCurrentWeather()
  }
  
  func locationDidUpdate(){
    currentLocation = UserSettings.currentLocation
  }
  
  func loadCurrentWeather(){
    guard let currentLocation = currentLocation  else { return }
    guard UserSettings.canUpdateForecast else { return }
    print("Starting forecast update")
    
    UserSettings.didUpdateForecast()
    APIClient.requestWeeklyForecast(for: currentLocation) { (dataPoints, error) in
      guard error == nil else {
        UserSettings.lastForecastUpdate = nil
        return
      }
      UserSettings.didUpdateForecast()
      self.historyDataPoints = dataPoints
    }
  }

}

extension WeekForecastViewController : UITableViewDataSource{

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return historyDataPoints.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = historyTableView.dequeueReusableCell(withIdentifier: WeekForecastViewCell.classString()) as! WeekForecastViewCell
    let point = historyDataPoints[indexPath.row]
    cell.set(to: point)
    return cell
  }
  
}

extension WeekForecastViewController : UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }
}
