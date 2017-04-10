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

/// Current API client is responsible for sending current weather and weekly forecasts requests
///
/// The client is using Forecast.io API to get the weather forecast
///
/// [Forecast.io Docs](https://darksky.net/dev/docs/forecast)
public final class APIClient{

  private static let baseURL = URL(string: "https://api.darksky.net/forecast")!
  private static let apiKey = "fe5ad50a5265afdb30d230872c6e2577"
  private static let apiURL = baseURL.appendingPathComponent(apiKey)
  
  private static let preferredLanguageCode : String = {
    guard let lang = Locale.preferredLanguages.first, lang.characters.count > 1  else { return "en" }
    let startIndex = lang.index(lang.startIndex, offsetBy: 0)
    let endIndex = lang.index(lang.startIndex, offsetBy: 1)
    return lang[startIndex...endIndex]
  }()
  
  
  /// Sends request to Forecast.io in order to get current weather in specified location.
  ///
  /// - Parameters:
  ///   - location: Location coordinates of a place that forecast is requested for.
  ///   - language: Language parameter of the readable summary like "Overcast", "Mostly Sunny" so that it will be shown on the weather display view.
  ///   - completion: Request completes either with an error with `ErrorType` type or `WeatherDataPoint` object which stores all required information.
  public static func requestCurrentForecast(for location : CLLocationCoordinate2D, language : String = preferredLanguageCode, completion : @escaping (_ dataPoint : WeatherDataPoint?,_ error : ErrorType?)->()){
    let url = requestURL(from: location)
    
    // Since current weathes is requested in order to minimize request size weekly forecast can be ignored
    let parameters : Parameters = ["lang" : [language], "exclude" : ["alerts","flags","daily"]]
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      
      // Possibly network error
      guard response.result.error == nil else {
        completion(nil, response.result.error?.type)
        return
      }
      // Possibly parsing error
      guard let responseDict = response.result.value as? [String : AnyObject] else{
        completion(nil, .wrongResponse)
        return
      }
      // Possibly parsing error
      guard let currentDict = responseDict["currently"] as? [String : AnyObject] else{
        completion(nil, .wrongResponse)
        return
      }

      let currentDataPoint = WeatherDataPoint(from: currentDict, location: location)
      completion(currentDataPoint, nil)
    }
  }
  
  /// Sends request to Forecast.io in order to get weekly forcast for the weather in specified location.
  ///
  /// - Parameters:
  ///   - location: Location coordinates of a place that forecast is requested for.
  ///   - language: Language parameter of the readable summary like "Overcast", "Mostly Sunny" so that it will be shown on the weather display view.
  ///   - completion: Request completes either with an error with `ErrorType` type or an array `WeatherDataPoint` objects (for each day of the week) which store all required information.
  public static func requestWeeklyForecast(for location : CLLocationCoordinate2D, language : String = preferredLanguageCode, completion : @escaping (_ dataPoints : [WeatherDataPoint],_ error : ErrorType?)->()){
    
    let url = requestURL(from: location)
    
    // Since weekly forecast is requested in order to minimize request size current forecast can be ignored
    let parameters : Parameters = ["lang" : [language], "exclude" : ["alerts","flags","currently"]]
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      
      // Possibly network error
      guard response.result.error == nil else {
        completion([], response.result.error?.type)
        return
      }
      
      // Possibly parsing error
      guard let responseDict = response.result.value as? [String : AnyObject] else{
        completion([], .wrongResponse)
        return
      }
      
      // Possibly parsing error
      guard let dailyDict = responseDict["daily"] as? [String : AnyObject], let dataDict = dailyDict["data"] as? [[String : AnyObject]] else{
        completion([], .wrongResponse)
        return
      }

      var points : [WeatherDataPoint] = []
      for dict in dataDict{
        if let point = WeatherDataPoint(from: dict, location: location){
          points.append(point)
        }
      }
      
      completion(points, nil)
      
    }
  }
  
  
  /// Generates weather forecast request URL. The URL is formatted accordingly Forecast.io documentation.
  ///
  /// - Parameter location: Location coordinates of a place that forecast is requested for.
  /// - Returns: Returns a URL where location coordinates are appended.
  /// **Example:**
  ///
  ///       https://api.darksky.net/forecast/0123456789/42.3601,-71.0589
  ///
  private static func requestURL(from location : CLLocationCoordinate2D)->URL{
    let locationString = [String(location.latitude),String(location.longitude)].joined(separator: ",")
    return apiURL.appendingPathComponent(locationString)
  }
  
}

extension Error{
  
  /// Computed property which reutrns a type of an error using `enum ErrorType`
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
