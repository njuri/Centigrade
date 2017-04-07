//
//  UserSettings.swift
//  Centigrade
//
//  Created by Juri Noga on 01.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CentigradeKit

enum UserDefaultsKey : String{
  case temperatureUnit
  case lastWeatherUpdate
}

struct UserSettings{

  /// Update weather not more frequently than 5 minutes
  static let weatherUpdateInterval : TimeInterval = 5 * 60
  static let measurementFormatter = MeasurementFormatter()
  static let weekdayDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "eeee"
    return formatter
  }()
  
  static var customTemperatureUnit : UnitTemperature?{
    get{
      guard let symbolString =  UserDefaults.standard.string(forKey: UserDefaultsKey.temperatureUnit.rawValue) else { return nil }
      switch symbolString{
      case UnitTemperature.celsius.symbol: return .celsius
      case UnitTemperature.fahrenheit.symbol: return .fahrenheit
      case UnitTemperature.kelvin.symbol: return .kelvin
      default: return nil
      }
    }set{
      UserDefaults.standard.set(newValue?.symbol, forKey: UserDefaultsKey.temperatureUnit.rawValue)
    }
  }
  
  static func didUpdateWeather(){
    lastWeatherUpdate = Date()
  }
  
  static var canUpdateWeather : Bool{
    guard let lastWeatherUpdate = lastWeatherUpdate else { return true }
    return Date().timeIntervalSince(lastWeatherUpdate) >= weatherUpdateInterval
  }

  static let defaultTemperatureUnit : UnitTemperature = {
    let mf = MeasurementFormatter()
    let a = Measurement(value: 0, unit: UnitTemperature.kelvin)
    let s = mf.string(from: a)
    return s.contains("C") ? .celsius : .fahrenheit
  }()
  
  static var currentTemperatureUnit : UnitTemperature{
    return customTemperatureUnit ?? defaultTemperatureUnit
  }
  
  static func localizedString(from temperature : Measurement<UnitTemperature>)->String{
    let converted = temperature.converted(to: currentTemperatureUnit)
    return String(Int(converted.value.rounded(.toNearestOrEven)))+"º"
  }
  
  private static var lastWeatherUpdate : Date?{
    get{
      return UserDefaults.standard.object(forKey: UserDefaultsKey.lastWeatherUpdate.rawValue) as? Date
    }set{
      UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.lastWeatherUpdate.rawValue)
    }
  }
  
}
