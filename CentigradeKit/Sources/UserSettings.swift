//
//  UserSettings.swift
//  Centigrade
//
//  Created by Juri Noga on 01.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation

struct UserSettings{

  static let measurementFormatter = MeasurementFormatter()
  
  static func localizedString(from temperature : Measurement<UnitTemperature>)->String{
    measurementFormatter.unitOptions = .temperatureWithoutUnit
    return measurementFormatter.string(from: temperature)
  }
  
  
  
}
