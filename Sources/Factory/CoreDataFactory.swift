//
//  CoreDataFactory.swift
//  Centigrade
//
//  Created by Juri Noga on 06.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import CoreData
import CentigradeKit

struct CoreDataFactory{
  
  private static let context = CoreDataStack.stack.managedObjectContext
  
  static func save(){
    CoreDataStack.stack.saveContext()
  }

  static func saveDataPoint(dataPoint : WeatherDataPoint)->WeatherDataArchiveObject{
    let entity = NSEntityDescription.insertNewObject(forEntityName: WeatherDataArchiveObject.classString(), into: context) as! WeatherDataArchiveObject
    entity.apparentTemperature = dataPoint.apparentTemperature.value
    entity.unitSymbol = dataPoint.temperature.unit.symbol
    entity.temperature = dataPoint.temperature.value
    entity.longitude = dataPoint.location.longitude
    entity.latitude = dataPoint.location.latitude
    entity.date = dataPoint.date as NSDate
    entity.summary = dataPoint.summary.rawValue
    entity.readableSummary = dataPoint.readableSummary
    return entity
  }
  
  static var user : UserObject{
    if let u = fetchUser(){
      return u
    }else{
      return createUser()
    }
  }
  
  private static func fetchUser()->UserObject?{
    let request : NSFetchRequest<UserObject> = UserObject.fetchRequest()
    request.fetchLimit = 1
    request.entity = NSEntityDescription.entity(forEntityName: UserObject.classString(), in: context)
    request.returnsObjectsAsFaults = false
    do{
      let result = try? context.fetch(request)
      if let result = result, result.count == 1{
        return result[0]
      }else{
        return nil
      }
    }
  }
  
  private static func createUser()->UserObject{
    return NSEntityDescription.insertNewObject(forEntityName: UserObject.classString(), into: context) as! UserObject
  }
  
}

extension WeatherDataArchiveObject{
  
  var measurementUnit : UnitTemperature{
    guard let symbolString = unitSymbol else { return .fahrenheit }
    switch symbolString{
    case UnitTemperature.celsius.symbol: return .celsius
    case UnitTemperature.fahrenheit.symbol: return .fahrenheit
    case UnitTemperature.kelvin.symbol: return .kelvin
    default: return .fahrenheit
    }
  }
  
//  var dataPoint : WeatherDataPoint?{
//    guard let summaryString = summary, let summary = WeatherSummary(rawValue: summaryString), let date = date else { return nil }
//    let d = WeatherDataPoint(apparentTemperatureValue: apparentTemperature, temperatureValue: temperature, summary: summary, latitude: latitude, longitude: longitude, date: date as Date, readableSummary: readableSummary, unit: measurementUnit)
//    return d
//  }
}

extension NSObject{
  static func classString()->String{
    return String(describing: self)
  }
}
