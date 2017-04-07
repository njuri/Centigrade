//
//  TemperatureDisplayLabel.swift
//  Centigrade
//
//  Created by Juri Noga on 07.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit

final class TemperatureDisplayLabel: UILabel {
  
  func set(to temperature : Measurement<UnitTemperature>?){
    guard let temperature = temperature else {
      text = "-"
      return
    }
    text = UserSettings.localizedString(from: temperature)
  }

}
