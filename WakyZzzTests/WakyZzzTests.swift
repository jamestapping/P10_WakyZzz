//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by James Tapping on 13/09/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

//  Tests TODO

// - Create Alarm and Core Data Persistance
// - Test alarm notifications scheduling
// - Test Delete alarm



import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {
    
    var dataManager: DataManager!
    var notificationScheduler: NotificationScheduler!
    var notificationCenter: UNUserNotificationCenter!
    
    var matchingUUID = ""
    var modifiedIdentifier = ""
    
    var notificationRequestsCount: Int?
    
    override func setUp() {
        super.setUp()
    
        notificationCenter = UNUserNotificationCenter.current()
        dataManager = DataManager()
        notificationScheduler = NotificationScheduler()
        
        deleteAllAlarms()
        
    }
    
    override func tearDown() {
        
        deleteAllAlarms()
    }
    
    
    func testCreateAlarmAndCoreDataPersistance() {
        
        // Test adding repeat alarm for 11.00 am monday,
        // and retrieveing it from CoreData
        
        let newAlarm = Alarm()
        
        let timeToTest = 11 * 3600 // 11.00 am
        let repeatDaysToTest:[Bool] = [false,true,false,false,false,false,false]
        
        // Create the new alarm
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        // Save to CoreData
        
        _ = dataManager.addAlarm(alarm: newAlarm)
        
        let retrievedManagedAlarm = dataManager.returnAllAlarms()[0]
        
        // Convert to Alarm object
        
        let alarm = dataManager.convertAlarm(managedAlarm: retrievedManagedAlarm)

        // Testing alarm time and repeat days
        
        XCTAssert(alarm.time == timeToTest)
        XCTAssert(alarm.repeatDays == repeatDaysToTest)
        XCTAssert(alarm.enabled == true)
        
    }
    
    func testDeleteAlarm() {
        
        // Test deleting alarm
        
        let newAlarm = Alarm()
        
        let timeToTest = 13 * 3600 // 1.00 pm
        let repeatDaysToTest:[Bool] = [false,true,false,true,false,false,true]
        
        // Create the new alarm
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        // Save to CoreData
        
        _ = dataManager.addAlarm(alarm: newAlarm)
        
        let retrievedManagedAlarm = dataManager.returnAllAlarms()[0]
        
        // Convert to Alarm object
        
        let alarm = dataManager.convertAlarm(managedAlarm: retrievedManagedAlarm)
        
        // delete the alarm
        
        dataManager.deleteAlarm(alarm: alarm)
        
        let allAlarms = dataManager.returnAllAlarms()
        
        XCTAssert(allAlarms.count == 0)
        
    }
    
    
    func testAlarmNotificationSchedulingEnable() {
        
        // Remove all notifications.
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        let newAlarm = Alarm()
        
        let timeToTest = 9 * 3600 // 9.00 am
        let repeatDaysToTest:[Bool] = [false,false,false,false,false,true,false]
        
        // Create the new alarm
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        let uuid = dataManager.addAlarm(alarm: newAlarm)
        
        // Add the notifications via the schedular.
        
        notificationScheduler.enableAlarm(alarm: newAlarm, uuid: uuid)
    
        // Check that a notification with the correct UUID has been scheduled.
        
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            for notificationRequest:UNNotificationRequest in notificationRequests {
                
                self.modifiedIdentifier = notificationRequest.identifier
                self.modifiedIdentifier.removeLast()
                
                if self.modifiedIdentifier == uuid.uuidString {
                    
                    self.matchingUUID = self.modifiedIdentifier
                
                }
                
            }
            
        }
        
        // Test enable - does the notification exist in the queue ?
    
        XCTAssert(self.matchingUUID == self.modifiedIdentifier)
        
    }
    
    func deleteAllAlarms() {
        
        dataManager.deleteAllData()
        
    }
    
}
