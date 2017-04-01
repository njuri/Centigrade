//
//  WeatherDataPoint.swift
//  Centigrade
//
//  Created by Juri Noga on 31.03.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CoreLocation

public enum WeatherSummary : String{
  case clearDay = "clear-day"
  case clearNight = "clear-night"
  case partlyCloudyDay = "partly-cloudy-day"
  case partlyCloudyNight = "partly-cloudy-night"
  case rain,snow,sleet,wind,fog,cloudy
}

public struct WeatherDataPoint{
  public let apparentTemperature : Measurement<UnitTemperature>
  public let temperature : Measurement<UnitTemperature>
  public let summary : WeatherSummary
  public let readableSummary : String
  public let location : CLLocationCoordinate2D
  public let date : Date
  
  public var displayTemperature : String{
    return UserSettings.localizedString(from: temperature)
  }
  
  public init?(from weatherDictionary : [String : AnyObject], location : CLLocationCoordinate2D){
    guard let apparentTemperature = weatherDictionary["apparentTemperature"] as? Double else { return nil }
    guard let temperature = weatherDictionary["temperature"] as? Double else { return nil }
    guard let iconSummary = weatherDictionary["icon"] as? String, let summary = WeatherSummary(rawValue: iconSummary) else { return nil }
    guard let readableSummary = weatherDictionary["summary"] as? String else { return nil }
    guard let time = weatherDictionary["time"] as? TimeInterval else { return nil }

    self.apparentTemperature = Measurement(value: apparentTemperature, unit: UnitTemperature.fahrenheit)
    self.temperature = Measurement(value: temperature, unit: UnitTemperature.fahrenheit)
    self.summary = summary
    self.readableSummary = readableSummary
    self.location = location
    date = Date(timeIntervalSince1970: time)
  }

}
