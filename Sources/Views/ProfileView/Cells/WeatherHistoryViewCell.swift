//
//  WeatherHistoryViewCell.swift
//  Centigrade
//
//  Created by Juri Noga on 08.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit

final class WeatherHistoryViewCell: UITableViewCell {
  
  @IBOutlet weak var placeButton: UIButton!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var temperatureLabel: TemperatureDisplayLabel!
  @IBOutlet weak var iconView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func set(to dataPoint : WeatherDataPoint){
    dateLabel.text = UserSettings.weatherHistoryDateFormater.string(from: dataPoint.date)
    temperatureLabel.set(to: dataPoint.temperature)
    iconView.image = dataPoint.summary.icon
    placeButton.setTitle("\(dataPoint.location.latitude), \(dataPoint.location.longitude)", for: .normal)
  }
  
  
}
