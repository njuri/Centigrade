//
//  UserSettings.swift
//  Centigrade
//
//  Created by Juri Noga on 01.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CentigradeKit
import CoreLocation

enum CentigradeNotification : String{
  case locationDidChange
  case unitsDidChange
  
  var notification : Notification.Name{
    return Notification.Name(rawValue)
  }
}

enum UserDefaultsKey : String{
  case temperatureUnit
  case lastWeatherUpdate
  case lastForecastUpdate
}

struct UserSettings{

  /// Update weather not more frequently than 5 minutes
  static let weatherUpdateInterval : TimeInterval = 5 * 60
  /// Update weather not more frequently than 20 minutes
  static let forecastUpdateInterval : TimeInterval = 20 * 60
  static let measurementFormatter = MeasurementFormatter()
  static let weekdayDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "eeee"
    return formatter
  }()
  
  static let weatherHistoryDateFormater : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM - H:mm"
    return formatter
  }()
  
  static let defaultTemperatureUnit : UnitTemperature = {
    let mf = MeasurementFormatter()
    let a = Measurement(value: 0, unit: UnitTemperature.kelvin)
    let s = mf.string(from: a)
    return s.contains("C") ? .celsius : .fahrenheit
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
      lastWeatherUpdate = nil
      lastForecastUpdate = nil
      UserDefaults.standard.set(newValue?.symbol, forKey: UserDefaultsKey.temperatureUnit.rawValue)
    }
  }
  
  static var currentTemperatureUnit : UnitTemperature{
    return customTemperatureUnit ?? defaultTemperatureUnit
  }
  
  static var currentLocation : CLLocationCoordinate2D?{
    didSet{
      NotificationCenter.default.post(name: CentigradeNotification.locationDidChange.notification, object: nil)
    }
  }
  
  static var canUpdateWeather : Bool{
    guard let lastWeatherUpdate = lastWeatherUpdate else { return true }
    return Date().timeIntervalSince(lastWeatherUpdate) >= weatherUpdateInterval
  }
  
  static var canUpdateForecast : Bool{
    guard let lastForecastUpdate = lastForecastUpdate else { return true }
    return Date().timeIntervalSince(lastForecastUpdate) >= forecastUpdateInterval
  }
  
  static func localizedString(from temperature : Measurement<UnitTemperature>)->String{
    let converted = temperature.converted(to: currentTemperatureUnit)
    return String(Int(converted.value.rounded(.toNearestOrEven)))+"°"
  }
  
  static func didUpdateWeather(){
    lastWeatherUpdate = Date()
  }
  
  static func didUpdateForecast(){
    lastForecastUpdate = Date()
  }
  
  
  static var lastWeatherUpdate : Date?{
    get{
      return UserDefaults.standard.object(forKey: UserDefaultsKey.lastWeatherUpdate.rawValue) as? Date
    }set{
      UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.lastWeatherUpdate.rawValue)
    }
  }
  
  static var lastForecastUpdate : Date?{
    get{
      return UserDefaults.standard.object(forKey: UserDefaultsKey.lastForecastUpdate.rawValue) as? Date
    }set{
      UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.lastForecastUpdate.rawValue)
    }
  }
  
}
