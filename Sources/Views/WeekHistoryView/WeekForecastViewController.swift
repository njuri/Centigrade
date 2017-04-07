//
//  WeekForecastViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 07.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit

final class WeekForecastViewController: UIViewController {
  
  @IBOutlet weak var historyTableView: UITableView!
  
  var historyDataPoints : [WeatherDataPoint] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    historyTableView.register(UINib(nibName: WeekHistoryViewCell.classString(), bundle:nil), forCellReuseIdentifier: WeekHistoryViewCell.classString())
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
    let cell = historyTableView.dequeueReusableCell(withIdentifier: WeekHistoryViewCell.classString()) as! WeekHistoryViewCell
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
