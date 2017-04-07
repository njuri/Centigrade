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
  
  static func fetchWeatherHistory(completion : @escaping (_ dataPoints : [WeatherDataPoint])->()){
    
    let request : NSFetchRequest<WeatherDataArchiveObject> = WeatherDataArchiveObject.fetchRequest()
    request.includesPropertyValues = true
    let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
      if let final = result.finalResult{
        completion(final.flatMap{dataPoint(from: $0)})
      }else{
        completion([])
      }
    }
    do{
      try context.execute(asyncRequest)
    } catch let error as NSError{
      print("Async fetch error")
      print(error.debugDescription)
      completion([])
    }

  }
  
  static func measurementUnit(from symbolString : String)->UnitTemperature{
      switch symbolString{
      case UnitTemperature.celsius.symbol: return .celsius
      case UnitTemperature.fahrenheit.symbol: return .fahrenheit
      case UnitTemperature.kelvin.symbol: return .kelvin
      default: return .fahrenheit
    }
  }
  
  static func dataPoint(from archiveObject : WeatherDataArchiveObject)->WeatherDataPoint?{
    guard let summaryString = archiveObject.summary, let summary = WeatherSummary(rawValue: summaryString), let date = archiveObject.date , let symbolString = archiveObject.unitSymbol, let readableSummary = archiveObject.readableSummary else { return nil }
    return WeatherDataPoint(apparentTemperatureValue: archiveObject.apparentTemperature, temperatureValue: archiveObject.temperature, summary: summary, latitude: archiveObject.latitude, longitude: archiveObject.longitude, date: date as Date, readableSummary: readableSummary, unit: measurementUnit(from: symbolString))
  }
  
}

// Causes segfault, using factory method instead

//extension WeatherDataArchiveObject{
//  
//  var dataPoint : WeatherDataPoint?{
//    guard let summaryString = summary, let summary = WeatherSummary(rawValue: summaryString), let date = date , let readableSummary = readableSummary, let symbolString = unitSymbol else { return nil }
//    let d = WeatherDataPoint(apparentTemperatureValue: apparentTemperature, temperatureValue: temperature, summary: summary, latitude: latitude, longitude: longitude, date: date as Date, readableSummary: readableSummary, unit: CoreDataFactory.measurementUnit(from: symbolString))
//    return d
//  }
//}

extension NSObject{
  static func classString()->String{
    return String(describing: self)
  }
}
