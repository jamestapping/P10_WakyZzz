//
//  DataManager.swift
//  WakyZzz
//
//  Created by James Tapping on 24/08/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var notificationScheduler = NotificationScheduler()
    
    // MARK:- Goal CRUD methods
    
    func addAlarm(alarm: Alarm ) -> UUID {
        
        let newAlarm = ManagedAlarm(context: context)
        let newRepeatDays = RepeatDays(context: context)
        
        let uuid = UUID()
        
        let sunday = alarm.repeatDays[0]
        let monday = alarm.repeatDays[1]
        let tuesday = alarm.repeatDays[2]
        let wednesday = alarm.repeatDays[3]
        let thursday = alarm.repeatDays[4]
        let friday = alarm.repeatDays[5]
        let saturday = alarm.repeatDays[6]
        
        
        newAlarm.uuid = uuid
        newAlarm.time = Int64(alarm.time)
        newAlarm.enabled = alarm.enabled
        
        newRepeatDays.managedAlarm = newAlarm
        newRepeatDays.monday = monday
        newRepeatDays.tuesday = tuesday
        newRepeatDays.wednesday = wednesday
        newRepeatDays.thursday = thursday
        newRepeatDays.friday = friday
        newRepeatDays.saturday = saturday
        newRepeatDays.sunday = sunday
        
        saveContext()
        
        return uuid
        
    }
    
    func deleteAlarm(alarm: Alarm) {
        
        let request = ManagedAlarm.fetchRequest() as NSFetchRequest<ManagedAlarm>
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedAlarm.uuid), alarm.uuid as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            if result.count != 0 {
                
                context.delete(result.first!)
                
                saveContext()
                
            } else { print ("Fetch result was empty for specified uuid : \(alarm.uuid)") }
            
        }
        
        catch {
            
            // Warning
            
        }
        
    }
    
    func updateAlarm(alarm: Alarm) {

        // Delete the alarm
        deleteAlarm(alarm:alarm)
        
        // Delete the corresponding Notification
        notificationScheduler.disableAlarm(alarm: alarm)
        
        
        // Add the new alarm and get its uuid 
        let uuid = addAlarm(alarm: alarm)
        
        // add or remove the corresponding notification
        
        alarm.enabled ? notificationScheduler.enableAlarm(alarm: alarm, uuid: uuid) : notificationScheduler.disableAlarm(alarm: alarm)
        
    }
    
    
    func returnRepeatDays(uuid: UUID) -> RepeatDays {
        
        var result:[RepeatDays] = []
        var first: RepeatDays?
        
        do {
            
            let request = RepeatDays.fetchRequest() as NSFetchRequest<RepeatDays>
            
            let pred = NSPredicate(format: "%K == %@", #keyPath(RepeatDays.managedAlarm.uuid), uuid as CVarArg)
            
            request.predicate = pred
            
            result = try context.fetch(request)
            
            first = result.first!
            
            return first!
            
        }
        
        
        catch {
            
            // Warning
            
        }
        
        return first!
        
    }
    
    func returnAllAlarms() -> [ManagedAlarm] {
        
        let request = ManagedAlarm.fetchRequest() as NSFetchRequest<ManagedAlarm>
        
        do {
            
            let result = try context.fetch(request)
            
            return result
        }
        
        catch {
            
            //
        }
        
        return []
    }
    
    
    // func returnSnoozeCount(for uuid: UUID) -> Int {
    
    func returnSnoozeCount(for alarm: Alarm) -> Int {
    
        var count:Int? = 0
        
        let request = ManagedAlarm.fetchRequest() as NSFetchRequest<ManagedAlarm>
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedAlarm.uuid), alarm.uuid as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            if result.count != 0 {
                
                count = Int(result[0].snoozeCount)
                
                saveContext()
                
            } else { print ("Fetch result was empty for specified uuid : \(alarm.uuid)") }
            
        }
        
        catch {
            
            // Warning
            
        }
        
        return count!
    }
    
    
    func resetSnoozeCount(for alarm: Alarm) {
        
        let snoozeCount =  0
        
        let request = ManagedAlarm.fetchRequest() as NSFetchRequest<ManagedAlarm>
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedAlarm.uuid), alarm.uuid as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            if result.count != 0 {
                
                result[0].snoozeCount = Int64(snoozeCount)
                
                saveContext()
                
            } else { print ("Fetch result was empty for specified uuid : \(alarm.uuid)") }
            
        }
        
        catch {
            
            // Warning
            
        }
        
        
    }
    
    
    func updateSnoozeCount(for alarm: Alarm) {
        
        let snoozeCount =  alarm.snoozeCount + 1
        
        let request = ManagedAlarm.fetchRequest() as NSFetchRequest<ManagedAlarm>
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedAlarm.uuid), alarm.uuid as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            if result.count != 0 {
                
                result[0].snoozeCount = Int64(snoozeCount)
                
                saveContext()
                
            } else { print ("Fetch result was empty for specified uuid : \(alarm.uuid)") }
            
        }
        
        catch {
            
            // Warning
            
        }
        
        
    }
    
    func saveContext() {
        do {
            try context.save()
        }
        catch {
            
            context.rollback()
        }
    }
    
    // Convert from coreData object to our Alarm object
    
    func convertAlarm(managedAlarm: ManagedAlarm) -> Alarm {
        
        var tmpRepeatDays = [Bool]()
        
        let convertedAlarm = Alarm()
        convertedAlarm.uuid = managedAlarm.uuid!
        convertedAlarm.time = Int(managedAlarm.time)
        convertedAlarm.enabled = managedAlarm.enabled
        convertedAlarm.snoozeCount = Int(managedAlarm.snoozeCount)
        
        // get the repeat days from core data
        
        let repeatDays = returnRepeatDays(uuid: managedAlarm.uuid!)
        
        let sunday = repeatDays.sunday
        let monday = repeatDays.monday
        let tuesday = repeatDays.tuesday
        let wednesday = repeatDays.wednesday
        let thursday = repeatDays.thursday
        let friday = repeatDays.friday
        let saturday = repeatDays.saturday
        
        tmpRepeatDays.append(contentsOf: [sunday,monday,tuesday,wednesday,thursday,friday,saturday])
        
        convertedAlarm.repeatDays = tmpRepeatDays
        
        return convertedAlarm
    }
    
    // Only used for Unit Tests
    
    func deleteAllData()  {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedAlarm")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        }
        catch{
            
            // Error
            
        }

        saveContext()
    
    }
}
