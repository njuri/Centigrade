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

public final class APIClient{
  
  private static let baseURL = URL(string: "https://api.darksky.net/forecast")!
  private static let apiKey = "fe5ad50a5265afdb30d230872c6e2577"
  private static let apiURL = baseURL.appendingPathComponent(apiKey)
  
  
  
  public static func requestForecast(for location : CLLocationCoordinate2D){
    
    
  }
  
  
}
