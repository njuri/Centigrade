//
//  CentigrateLocationManager.swift
//  Centigrade
//
//  Created by Juri Noga on 01.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import Foundation
import CoreLocation

fileprivate enum PermissionStatus {
  case authorized,denied,disabled,notDetermined
}

public protocol LocationManagerDelegate {
  func didUpdateLocationAuthorizationStatus()
  func didReceive(location : CLLocation)
  func didFailToReceiveLocation()
}

public final class CentigradeLocationManager : NSObject {
  
  public var delegate : LocationManagerDelegate?

  public var isAuthorized : Bool {
    return CentigradeLocationManager.locationWhenInUseStatus == .authorized
  }
  
  public var notDetermined : Bool{
    return CentigradeLocationManager.locationWhenInUseStatus == .notDetermined
  }
  
  private let geocoder = CLGeocoder()
  private let clLocationManger : CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
    return manager
  }()

  private static var locationWhenInUseStatus : PermissionStatus{
    guard CLLocationManager.locationServicesEnabled() else { return .disabled }
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse: return .authorized
    case .restricted, .denied: return .authorized
    case .notDetermined: return .notDetermined
    }
  }
  
  public override init() {
    super.init()
    clLocationManger.delegate = self
  }
  
  public func requestPermission(){
    clLocationManger.requestWhenInUseAuthorization()
  }
  
  public func requestCurrentLocation(){
    guard isAuthorized else { return }
    clLocationManger.requestLocation()
  }

  
  /// Returns either city (or city area) or country name based on given location.
  ///
  /// - Parameters:
  ///   - location: Geographic location of requested place.
  ///   - completion: If geocoding operation succeeds then returns either city or country name otherwise returns `nil`.
  ///   - locality: City or country name. Optional.
  public func placemarkLocality(from location : CLLocation, completion : @escaping (_ locality : String?) ->()){
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      guard let firstPlacemark = placemarks?.first, error == nil else {
        completion(nil)
        return
      }
      completion(firstPlacemark.locality ?? firstPlacemark.country)
    }
  }
}

extension CentigradeLocationManager : CLLocationManagerDelegate{
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    delegate?.didUpdateLocationAuthorizationStatus()
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    delegate?.didFailToReceiveLocation()
  }
  
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let recentLocation = locations.last else{
      delegate?.didFailToReceiveLocation()
      return
    }
    delegate?.didReceive(location: recentLocation)
  }
}
