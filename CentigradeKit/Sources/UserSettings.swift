//
//  UserSettings.swift
//  Centigrade
//
//  Created by Juri Noga on 01.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation

public struct UserSettings{

  static let measurementFormatter = MeasurementFormatter()
  
  public static var customTemperatureUnit : UnitTemperature?
  
  public static let defaultTemperatureUnit : UnitTemperature = {
    let mf = MeasurementFormatter()
    let a = Measurement(value: 0, unit: UnitTemperature.kelvin)
    let s = mf.string(from: a)
    return s.contains("C") ? .celsius : .fahrenheit
  }()
  
  public static var currentTemperatureUnit : UnitTemperature{
    return customTemperatureUnit ?? defaultTemperatureUnit
  }
  
  public static func localizedString(from temperature : Measurement<UnitTemperature>)->String{
    let converted = temperature.converted(to: currentTemperatureUnit)
    return String(Int(converted.value.rounded(.toNearestOrEven)))+"º"
  }
  
  
  
}
