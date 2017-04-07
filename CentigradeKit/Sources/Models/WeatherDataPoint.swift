//
//  WeatherDataPoint.swift
//  Centigrade
//
//  Created by Juri Noga on 31.03.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CoreLocation

public struct WeatherDataPoint{
  public let apparentTemperature : Measurement<UnitTemperature>
  public let temperature : Measurement<UnitTemperature>
  public let summary : WeatherSummary
  public let readableSummary : String
  public let location : CLLocationCoordinate2D
  public let date : Date
  public let temperatureInterval : TemperatureInterval?
  
  public init(apparentTemperatureValue : Double, temperatureValue : Double, summary : WeatherSummary, latitude : Double, longitude : Double, date : Date, readableSummary : String, unit : UnitTemperature){
    apparentTemperature = Measurement(value: apparentTemperatureValue, unit: unit)
    temperature = Measurement(value: temperatureValue, unit: unit)
    location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.readableSummary = readableSummary
    self.date = date
    self.summary = summary
    temperatureInterval = nil
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
    
    guard let minTemperatureValue = weatherDictionary["temperatureMin"] as? Double, let maxTemperatureValue = weatherDictionary["temperatureMax"] as? Double else {
      temperatureInterval = nil
      return
    }
    let minTemperature = Measurement(value: minTemperatureValue, unit: UnitTemperature.fahrenheit)
    let maxTemperature = Measurement(value: maxTemperatureValue, unit: UnitTemperature.fahrenheit)
    temperatureInterval = TemperatureInterval(minTemperature: minTemperature, maxTemperature: maxTemperature)
  }

}
