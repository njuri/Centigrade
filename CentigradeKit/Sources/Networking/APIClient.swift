//
//  APIClient.swift
//  Centigrade
//
//  Created by Juri Noga on 31.03.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

public enum ErrorType{
  case noNetwork,wrongResponse,other
}

public final class APIClient{
  
  private static let baseURL = URL(string: "https://api.darksky.net/forecast")!
  private static let apiKey = "fe5ad50a5265afdb30d230872c6e2577"
  private static let apiURL = baseURL.appendingPathComponent(apiKey)
  
  private static let preferredLanguageCode : String = {
    return Locale.preferredLanguages.first ?? "en"
  }()
  
  public static func requestCurrentForecast(for location : CLLocationCoordinate2D, language : String = preferredLanguageCode, completion : @escaping (_ dataPoint : WeatherDataPoint?,_ error : ErrorType?)->()){
    let url = requestURL(from: location)
    let parameters : Parameters = ["lang" : [language], "exclude" : ["alerts","flags","daily"]]
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      
      guard response.result.error == nil else {
        completion(nil, response.result.error?.type)
        return
      }
      guard let responseDict = response.result.value as? [String : AnyObject] else{
        completion(nil, .wrongResponse)
        return
      }
      guard let currentDict = responseDict["currently"] as? [String : AnyObject] else{
        completion(nil, .wrongResponse)
        return
      }

      let currentDataPoint = WeatherDataPoint(from: currentDict, location: location)
      completion(currentDataPoint, nil)
    }
  }
  
  public static func requestWeeklyForecast(for location : CLLocationCoordinate2D, language : String = preferredLanguageCode, completion : @escaping (_ dataPoints : [WeatherDataPoint],_ error : ErrorType?)->()){
    let url = requestURL(from: location)
    let parameters : Parameters = ["lang" : [language], "exclude" : ["alerts","flags","currently"]]
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      
      guard response.result.error == nil else {
        completion([], response.result.error?.type)
        return
      }
      guard let responseDict = response.result.value as? [String : AnyObject] else{
        completion([], .wrongResponse)
        return
      }
      
      guard let dailyDict = responseDict["daily"] as? [String : AnyObject], let dataDict = dailyDict["data"] as? [[String : AnyObject]] else{
        completion([], .wrongResponse)
        return
      }

      var points : [WeatherDataPoint] = []
      for dict in dataDict{
        guard let point = WeatherDataPoint(from: dict, location: location) else { continue }
        
        points.append(point)
      }
      
      completion(points, nil)
      
    }
  }
  
  private static func requestURL(from location : CLLocationCoordinate2D)->URL{
    let locationString = [String(location.latitude),String(location.longitude)].joined(separator: ",")
    return apiURL.appendingPathComponent(locationString)
  }
  
}

extension Error{
  
  var type : ErrorType{
    let code = (self as NSError).code
    print("ERROR WITH CODE \(code)")
    if code == -1009{
      return .noNetwork
    }else{
      return .other
    }
  }
  
}
