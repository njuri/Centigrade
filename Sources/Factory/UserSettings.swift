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
}

struct UserSettings{

  static let measurementFormatter = MeasurementFormatter()
  
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
  
  
  
  
}

extension WeatherDataPoint{
  public var displayTemperature : String{
    return UserSettings.localizedString(from: temperature)
  }
}
