//
//  WeatherDataPoint.swift
//  Centigrade
//
//  Created by Juri Noga on 31.03.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CoreLocation


/// Represents the weather data at specific date in specific location.
public struct WeatherDataPoint{
  
  /// Temperature at specific date.
  public let temperature : Measurement<UnitTemperature>
  /// A kind of the weather in order to show proper icon (sun - for sunny weather, snowflake - for snow etc.).
  public let summary : WeatherSummary
  /// String that will be displayed to the user as a description of the weather.
  public let readableSummary : String
  
  /// Specific location representing current temperature
  public let location : CLLocationCoordinate2D
  
  /// Specific point in time representing current temperature
  public let date : Date
  
  /// Temperature interval that contains approximate maximal and minimal temperatures at specific date.
  public let temperatureInterval : TemperatureInterval?
  
  /// This method is used to initialize a data point from the Core Data store.
  public init(apparentTemperatureValue : Double, temperatureValue : Double, summary : WeatherSummary, latitude : Double, longitude : Double, date : Date, readableSummary : String, unit : UnitTemperature){
    temperature = Measurement(value: temperatureValue, unit: unit)
    location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.readableSummary = readableSummary
    self.date = date
    self.summary = summary
    temperatureInterval = nil
  }
  
  
  public init?(from weatherDictionary : [String : AnyObject], location : CLLocationCoordinate2D){
    guard let iconSummary = weatherDictionary["icon"] as? String, let summary = WeatherSummary(rawValue: iconSummary) else { return nil }
    guard let readableSummary = weatherDictionary["summary"] as? String else { return nil }
    guard let time =
      weatherDictionary["time"] as? TimeInterval else { return nil }

    self.summary = summary
    self.readableSummary = readableSummary
    self.location = location
    date = Date(timeIntervalSince1970: time)
    
    if let minTemperatureValue = weatherDictionary["temperatureMin"] as? Double, let maxTemperatureValue = weatherDictionary["temperatureMax"] as? Double{
      temperature = Measurement(value: (minTemperatureValue+maxTemperatureValue)/2, unit: UnitTemperature.fahrenheit)
      let minTemperature = Measurement(value: minTemperatureValue, unit: UnitTemperature.fahrenheit)
      let maxTemperature = Measurement(value: maxTemperatureValue, unit: UnitTemperature.fahrenheit)
      temperatureInterval = TemperatureInterval(minTemperature: minTemperature, maxTemperature: maxTemperature)
    }else {
      temperatureInterval = nil
      guard let temperature = weatherDictionary["temperature"] as? Double else { return nil }
      self.temperature = Measurement(value: temperature, unit: UnitTemperature.fahrenheit)
    }

  }

}
