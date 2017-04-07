//
//  WeekHistoryViewCell.swift
//  Centigrade
//
//  Created by Juri Noga on 07.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit

final class WeekHistoryViewCell: UITableViewCell {
  
  @IBOutlet weak var weekdayLabel: UILabel!
  @IBOutlet weak var highTemperatureLabel: TemperatureDisplayLabel!
  @IBOutlet weak var lowTemperatureLabel: TemperatureDisplayLabel!
  @IBOutlet weak var temperatureLabel: TemperatureDisplayLabel!
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var highTemperatureIcon: UIImageView!
  @IBOutlet weak var lowTemperatureIcon: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    lowTemperatureIcon.transform = CGAffineTransform(rotationAngle: .pi)
    lowTemperatureIcon.image = lowTemperatureIcon.image?.withRenderingMode(.alwaysTemplate)
    highTemperatureIcon.image = highTemperatureIcon.image?.withRenderingMode(.alwaysTemplate)
    lowTemperatureIcon.tintColor = UIColor(white: 0.7, alpha: 1)
    highTemperatureIcon.tintColor = lowTemperatureIcon.tintColor
  }
  
  func set(to dataPoint: WeatherDataPoint){
    temperatureLabel.set(to: dataPoint.temperature)
    weekdayLabel.text = UserSettings.weekdayDateFormatter.string(from: dataPoint.date).capitalized
    iconView.image = dataPoint.summary.icon
    
    guard let tempInterval = dataPoint.temperatureInterval else {
      highTemperatureLabel.set(to: nil)
      lowTemperatureLabel.set(to: nil)
      return
    }
    highTemperatureLabel.set(to: tempInterval.maxTemperature)
    lowTemperatureLabel.set(to: tempInterval.minTemperature)
  }
  
}
