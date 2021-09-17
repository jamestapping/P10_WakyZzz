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
// - Test alarm defaults to 8:00 am
// - Test non repeating alarm created for the same day
// - Test Alarm disabled, corresponding notification should be removed, Alarm remains in CoreData


import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {
    
    var dataManager: DataManager!
    var notificationScheduler: NotificationScheduler!
    var notificationCenter: UNUserNotificationCenter!
    
    var matchingUUID = ""
    var modifiedIdentifier = ""
    
    var scheduledState = false
    
    
    var notificationRequestsCount: Int?
    
    override func setUp() {
        super.setUp()
        
        notificationCenter = UNUserNotificationCenter.current()
        dataManager = DataManager()
        notificationScheduler = NotificationScheduler()
        
        removeAllNotifications()

        deleteAllAlarms()
        
    }
    
    override func tearDown() {
        
        removeAllNotifications()

        deleteAllAlarms()
    }
    
    
    func testGivenAlarmSetbyUser_WhenAppIsKilled_AlarmAvailableWhenAppRun() {
        
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
        
        // Testing alarm time and repeat days correspond to what was defined
        
        XCTAssert(alarm.time == timeToTest)
        XCTAssert(alarm.repeatDays == repeatDaysToTest)
        XCTAssert(alarm.enabled == true)
        
    }
    
    func testGivenNoAlarmIsSet_WhenUserCreatesAlarmWithNoDaysSpecified_AlarmIsSetForCurrentDayWithNoRepeat() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let dayOfMonth = Int(formatter.string(from: Date()))
        
        let newAlarm = Alarm()
        
        let timeToTest = 18 * 3600 // 18.00 am
        
        newAlarm.time = timeToTest
        
        // Save to CoreData
        
        let uuid = dataManager.addAlarm(alarm: newAlarm)
        
        // Schedule the alarm
        
        notificationScheduler.enableAlarm(alarm: newAlarm, uuid: uuid)
        
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            for notificationRequest:UNNotificationRequest in notificationRequests {
                
                if let calendarNotificationTrigger = notificationRequest.trigger as? UNCalendarNotificationTrigger {
                    
                    let triggerDate = calendarNotificationTrigger.nextTriggerDate()
                    let repeats = calendarNotificationTrigger.repeats
                    
                    let scheduledHour = Calendar.current.component(.hour, from: triggerDate!)
                    let scheduledMinute = Calendar.current.component(.minute, from: triggerDate!)
                    let scheduledDay = Calendar.current.component(.day, from: triggerDate!)
                    
                    // Test time and day and repeat status
                    
                    let hourToTest = timeToTest/3600
                    let minuteToTest = timeToTest/60 - hourToTest * 60
                    
                    // Confirm that the Notification has the correct time
                    
                    XCTAssert(scheduledHour == hourToTest)
                    XCTAssert(scheduledMinute == minuteToTest)
                    
                    // Confirm that the notification was set for the correct day (ie. today)
                    
                    XCTAssert(scheduledDay == dayOfMonth)
                    
                    // Confirm that the notification is non repeating
                    
                    XCTAssert(repeats == false)
                    
                }
                
            }
            
        }
        
    }
    
    
    func testGivenAlarmCreated_WhenUserDisablesAlarm_AlarmIsDisabled() {
        
        // - Test Alarm disabled, corresponding notification should be removed, Alarm still in CoreData
        
        let exp = expectation(description: "Check Schedule State - false")
        
        // Create an alarm
        
        let newAlarm = Alarm()
        let timeToTest = 6 * 3600 // 6.00 am
        let repeatDaysToTest:[Bool] = [false,false,false,false,false,true,false]
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        // Save to CoreData
        
        _ = dataManager.addAlarm(alarm: newAlarm)
        
        var retrievedManagedAlarm = dataManager.returnAllAlarms()[0]
        
        // Convert to Alarm object
        
        let alarm = dataManager.convertAlarm(managedAlarm: retrievedManagedAlarm)
        
        // Enable the alarm
        
        notificationScheduler.enableAlarm(alarm: alarm, uuid: alarm.uuid)
        
        // Simulate disable tha alarm notification
        
        alarm.enabled = false
        dataManager.updateAlarm(alarm: alarm)
        
        // get the alarms uuid and check that the notification has been removed
        
        retrievedManagedAlarm = dataManager.returnAllAlarms()[0]
        
        let uuid = retrievedManagedAlarm.uuid
        
        confirmNotificationIsPending(for: uuid!) { [self] scheduled in
            
            // Test enable - does the notification exist in the queue ?
        
            scheduledState = scheduled
            
            exp.fulfill()
            
            
        }
    
        waitForExpectations(timeout: 2) { [self] error in
            
            if let error = error {
                
                        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                    }
            
            XCTAssertEqual(scheduledState, false)
            
        }
        
        
        
    }
    
    func testGivenTwoAlarmsCreated_UserDeletesOneAlarm_OneAlarmIsRemainsAndOneNotificationRemains() {
        
        let exp = expectation(description: "Check Schedule State for notification uuidOne - true")
        
        let newAlarm = Alarm()
        var timeToTest = 6 * 3600 // 6.00 am
        var repeatDaysToTest:[Bool] = [false,false,false,false,false,true,false]
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        // Save to CoreData
        
        let uuidOne = dataManager.addAlarm(alarm: newAlarm)
        
        // Schedule the alarm notification
        
        notificationScheduler.enableAlarm(alarm: newAlarm, uuid: uuidOne)
        
        timeToTest = 13 * 3600 // 1:00 pm
        repeatDaysToTest = [false,true,false,false,false,false,false]
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        // Save to CoreData
        
        let uuidTwo = dataManager.addAlarm(alarm: newAlarm)
        
        // Schedule the alarm notification
        
        notificationScheduler.enableAlarm(alarm: newAlarm, uuid: uuidTwo)
        
        // Simulate deleting an alarm
        
        var alarms = dataManager.returnAllAlarms()
        let alarm = dataManager.convertAlarm(managedAlarm: alarms[0])
        
        dataManager.deleteAlarm(alarm: alarm)
        
        notificationScheduler.disableAlarm(alarm: alarm)
        
        // Confirm that only one alarm exists with the corresponding alarm notification
        
        alarms = dataManager.returnAllAlarms()
        
        // Assert only one ManagedAlarm object remains
        
        XCTAssert(alarms.count == 1)
        
        
        // Check that a notification with the correct UUID is still pending

        confirmNotificationIsPending(for: uuidOne) { [self] scheduled in
            
            // Test enable - does the notification exist in the queue ?
        
            scheduledState = scheduled
            
            exp.fulfill()
            
        }
    
        
        waitForExpectations(timeout: 2) { [self] error in

            if let error = error {

                        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                    }

            // Still pending ?

            XCTAssertEqual(scheduledState, true)

        }
        
        
    }
    
    
    func testGivenAlarmCreated_WhenUserDeletesAlarm_AlarmIsDeleted() {
        
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
    
    
    func testGivenAlarmIsCreatedAndNotificationIsScheduled_CorrespondingNotificationIdentifierIsPending() {
        
        // Test that once an alarm has been created and     a notification with it, that a notification is
        // pending with the correct identifier
        
        let exp = expectation(description: "Check Schedule State - false")
        
        let newAlarm = Alarm()
        
        let timeToTest = 9 * 3600 // 9.00 am
        let repeatDaysToTest:[Bool] = [false,false,false,false,false,true,false]
        
        // Create the new alarm
        
        newAlarm.time = timeToTest
        newAlarm.repeatDays = repeatDaysToTest
        
        let uuid = dataManager.addAlarm(alarm: newAlarm)
        
        // Add the notifications via the schedular.
        
        notificationScheduler.enableAlarm(alarm: newAlarm, uuid: uuid)

        // Check that a notification with the correct UUID is pending

        confirmNotificationIsPending(for: uuid) { [self] scheduled in
            
            // Test enable - does the notification exist in the queue ?
        
            scheduledState = scheduled
            
            exp.fulfill()
            
            
        }
    
        waitForExpectations(timeout: 2) { [self] error in
            
            if let error = error {
                
                        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                    }
            
            XCTAssertEqual(scheduledState, true)
            
        }
        
    
       
        
        
    }
    
    func testGivenNoAlarmExists_WhenUserAddsDefaultAlarm_alarmTimeIsSetTo8am() {
        
        // Testing alarm defaults to 8:00 am when nothing specified
        
        let newAlarm = Alarm()
        
        // Save to CoreData
        
        _ = dataManager.addAlarm(alarm: newAlarm)
        
        let retrievedManagedAlarm = dataManager.returnAllAlarms()[0]
        
        // Convert to Alarm object
        
        let alarm = dataManager.convertAlarm(managedAlarm: retrievedManagedAlarm)
        
        XCTAssert(alarm.time == 8 * 3600)
        
        
    }
    
    
    // Helper Methods
    
    func confirmNotificationIsPending(for uuid: UUID, completion: @escaping  (Bool) -> Void) {
        
        var modifiedIdentifier = ""
        
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            
            if notificationRequests.count != 0 {
                
                modifiedIdentifier = notificationRequests[0].identifier
                modifiedIdentifier.removeLast()
                
                completion(modifiedIdentifier == uuid.uuidString)
                
            } else {
                
                completion(false)
                
            }
            
        }
        
    }
    
    func removeAllNotifications() {
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
    }
    
    func deleteAllAlarms() {
        
        dataManager.deleteAllData()
        
    }
    
}
