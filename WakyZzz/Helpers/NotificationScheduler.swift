//
//  AlarmScheduler.swift
//  WakyZzz
//
//  Created by James Tapping on 30/08/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import NotificationCenter

class NotificationScheduler {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var triggerDays:[Int] = []
    
    init() {
        
        setupNotificationActions()
        
    }
    
    // Used for debug to show scheduled alarms
    
    func showPending() {
        
        print ("__________________________________________________________________________")
        
        print("Show Pending says:")
        
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            
            print("Requests: \(notificationRequests.count)")
        }
        
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request.identifier)
                print(request.trigger as Any)
            }
        })
        
        print ("__________________________________________________________________________")
    }
    
    func disableAlarm(alarm: Alarm) {
        
        let uuid = alarm.uuid.uuidString
        
        notificationCenter.getPendingNotificationRequests { [self] (notifications) in
            for item in notifications {
                
                if(item.identifier.contains(uuid)) {
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                    
                }
            }
        }
        
    }
    
    func enableAlarm(alarm: Alarm, uuid: UUID) {
        
        let identifier = uuid.uuidString
        
        var repeats:Bool = true
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let content = UNMutableNotificationContent()
        content.title = "WakeyZZz"
        content.body = "Time to wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Alarm_Loud.wav"))
        content.categoryIdentifier = "snoozeCatagory"
        
        // Get hours and minutes from time (Integar)
        
        let h = alarm.time/3600
        let m = alarm.time/60 - h * 60
        
        // Take into account that this may be a one time alarm to make sure we trigger on the correct day
        
        if alarm.scheduleDays.count != 0 {
            
            triggerDays = alarm.scheduleDays
            
        } else {
            
            let dayOfWeek = Calendar.current.component(.weekday, from: Date())
            repeats = false
            
            triggerDays = [dayOfWeek]
            
        }
        
        var dateInfo = DateComponents()
        
        for triggerDay in triggerDays {
            
            dateInfo.hour = h
            dateInfo.minute = m
            dateInfo.weekday = triggerDay
            dateInfo.timeZone = .current
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: repeats)
            
            // Using "String(triggerDay)" to distinguish between multiple notifications
            
            scheduleNotification(id: identifier + String(triggerDay), content: content, trigger: trigger)
            
        }
        
    }
    
    func setupNotificationActions() {
        
        let snoozeAction = UNNotificationAction(identifier: "snoozeAction",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions.init(rawValue: 0))
        
        let stopAction = UNNotificationAction(identifier: "stopAction",
                                              title: "Stop Alarm",
                                              options: UNNotificationActionOptions.init(rawValue: 0))
        
        let remindMeLaterAction = UNNotificationAction(identifier: "remindMeLaterAction",
                                                       title: "Remind me later",
                                                       options: UNNotificationActionOptions.init(rawValue: 0))
        
        let completedAction = UNNotificationAction(identifier: "completedAction",
                                                   title: "Mark as completed",
                                                   options: UNNotificationActionOptions.init(rawValue: 0))
        
        let snoozeActionCatagory = UNNotificationCategory(identifier: "snoozeCatagory",
                                                          actions: [snoozeAction, stopAction],
                                                          intentIdentifiers: [],
                                                          hiddenPreviewsBodyPlaceholder: "",
                                                          options: .customDismissAction)
        let actOfKindnessActionCatagory = UNNotificationCategory(identifier: "actOfKindnessCatagory",
                                                                 actions: [remindMeLaterAction, completedAction],
                                                                 intentIdentifiers: [],
                                                                 hiddenPreviewsBodyPlaceholder: "",
                                                                 options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([snoozeActionCatagory, actOfKindnessActionCatagory])
        
    }
    
    func scheduleNotification(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger){
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
                
                return
            }
            
        }
    }
    
    func manageSnooze(alarm: Alarm) {
        
        let content = buildNotificationContent(for: alarm)
        let identifier = alarm.uuid.uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        scheduleNotification(id: identifier + "9", content: content, trigger: trigger)
        
    }
    
    // Create reminder for random Act of kindness
    
    func createReminder(alarm: Alarm) {
        
        let identifier = alarm.uuid.uuidString
        let content = buildNotificationContent(for: alarm)
        
        // Set a reminder for 30 minutes from now
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
        
        scheduleNotification(id: identifier, content: content, trigger: trigger)
        
    }
    
    func buildNotificationContent(for alarm: Alarm) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        
        switch alarm.snoozeCount {
        
        case 0:
            content.title = "WakeyZZz"
            content.body = "First snooze alarm sir!"
            content.categoryIdentifier = "snoozeCatagory"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Alarm_Quiet.wav"))
            
        case 1:
            content.title = "WakeyZZz"
            content.body = "This is the second snooze alarm!"
            content.categoryIdentifier = "snoozeCatagory"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Alarm_Loud.wav"))
            
        default:
            content.title = "WakeyZZz - Too much snoozing!"
            content.body = "Make it right by \(Constants.randomActsOfKindness.randomElement()!)"
            content.categoryIdentifier = "actOfKindnessCatagory"
            content.userInfo = ["actOfKindness": content.body]
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Alarm_Evil.wav"))
            
        }
        
        return content
    }
    
}

