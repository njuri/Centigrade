//
//  NotificationManager.swift
//  Centigrade
//
//  Created by Juri Noga on 08.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UserNotifications

enum NotificationIdentifier : String{
  case dailyCheck
}

struct NotificationManager {
  
  static let center = UNUserNotificationCenter.current()
  
  static func authorizationStatus(completion : @escaping (_ isAuthorized : Bool)->()){
    center.getNotificationSettings { settings in
      completion(settings.authorizationStatus == .authorized)
    }
  }
  
  static func registerForNotifications(){
    let options : UNAuthorizationOptions = [.alert,.sound]
    
    center.requestAuthorization(options: options) { hasGranted, error in
      if hasGranted{
        createNotificationRequest()
      }else{
        print("Failed to register for notifications")
      }
    }
  }
  
  static func createNotificationRequest(){
    let content = UNMutableNotificationContent()
    content.body = NSLocalizedString("ITS_TIME_TO_CHECK_THE_WEATHER", comment: "It's time to check the weather!")
    content.sound = UNNotificationSound.default()
  
    let hoursOffset = TimeInterval(TimeZone.current.secondsFromGMT())/3600
    let triggerDate = Date(timeIntervalSince1970: (12-hoursOffset)*60*60+60*2)
    let triggerComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: triggerDate)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
    let notificationRequest = UNNotificationRequest(identifier: NotificationIdentifier.dailyCheck.rawValue, content: content, trigger: trigger)
    
    center.add(notificationRequest) { error in
      if error == nil{
        
      }else{
        print("Failed to add notification request")
      }
    }
    

  }
  
}
