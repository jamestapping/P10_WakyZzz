//
//  AppDelegateExtension.swift
//  WakyZzz
//
//  Created by James Tapping on 12/09/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification:
        UNNotification, withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .list, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        var identifier = response.notification.request.identifier
        
        // Make sure the identifier is 36 characters long and so still a uuid string
        // Required because I am adding a day of week number to differentiate notifications (identifier)
        
        
        if identifier.count == 37 {
            
            identifier.removeLast()
            
        }
        
        let identifierToSend:[AnyHashable:Any] = ["identifier":identifier]
        
        switch response.actionIdentifier {
        
        case "snoozeAction":
            
            nc.post(name: Notification.Name("didTapSnooze"), object: nil, userInfo: identifierToSend )
            
        case "remindMeLaterAction":
        
            nc.post(name: Notification.Name("didTapRemindMeLaterAction"), object: nil, userInfo: identifierToSend )
        
        case "stopAction", "completedAction":
        
            nc.post(name: Notification.Name("didTapCompletedOrStop"), object: nil, userInfo: identifierToSend )
            
        default:
            
            // Also fires when "clear" is used
            
            nc.post(name: Notification.Name("didTapNotification"), object: nil, userInfo: identifierToSend )
            
            break
        }
        
        completionHandler()
        
    }
    
    
}
