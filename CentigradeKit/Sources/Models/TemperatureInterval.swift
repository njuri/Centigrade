//
//  TemperatureInterval.swift
//  Centigrade
//
//  Created by Juri Noga on 07.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation


/// Temperature interval that represents minimal and maximal temperature for a specific weather forecast.
public struct TemperatureInterval{
  
  /// Minmal temperature that is expected at specific date.
  public let minTemperature : Measurement<UnitTemperature>
  
  /// Maximal temperature that is expected at specific date.
  public let maxTemperature : Measurement<UnitTemperature>
}
