//
//  WeatherSummary.swift
//  Centigrade
//
//  Created by Juri Noga on 03.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation

public enum WeatherSummary : String{
  case clearDay = "clear-day"
  case clearNight = "clear-night"
  case partlyCloudyDay = "partly-cloudy-day"
  case partlyCloudyNight = "partly-cloudy-night"
  case rain,snow,sleet,wind,fog,cloudy
  
  public var icon : UIImage{
    switch self {
    case .clearDay: return #imageLiteral(resourceName: "clear-day")
    case .clearNight: return #imageLiteral(resourceName: "clear-night")
    case .partlyCloudyDay: return #imageLiteral(resourceName: "partly-cloudy-day")
    case .partlyCloudyNight: return #imageLiteral(resourceName: "partly-cloudy-night")
    case .rain: return #imageLiteral(resourceName: "rain")
    case .snow: return #imageLiteral(resourceName: "snow")
    case .sleet: return #imageLiteral(resourceName: "sleet")
    case .wind: return #imageLiteral(resourceName: "wind")
    case .fog: return #imageLiteral(resourceName: "fog")
    case .cloudy: return #imageLiteral(resourceName: "cloudy")
    }
  }
}
