//
//  ManagedAlarm+CoreDataProperties.swift
//  WakyZzz
//
//  Created by James Tapping on 06/09/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedAlarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAlarm> {
        return NSFetchRequest<ManagedAlarm>(entityName: "ManagedAlarm")
    }

    @NSManaged public var enabled: Bool
    @NSManaged public var time: Int64
    @NSManaged public var uuid: UUID?
    @NSManaged public var snoozeCount: Int64
    @NSManaged public var repeatDays: NSSet?

}

// MARK: Generated accessors for repeatDays
extension ManagedAlarm {

    @objc(addRepeatDaysObject:)
    @NSManaged public func addToRepeatDays(_ value: RepeatDays)

    @objc(removeRepeatDaysObject:)
    @NSManaged public func removeFromRepeatDays(_ value: RepeatDays)

    @objc(addRepeatDays:)
    @NSManaged public func addToRepeatDays(_ values: NSSet)

    @objc(removeRepeatDays:)
    @NSManaged public func removeFromRepeatDays(_ values: NSSet)

}

extension ManagedAlarm : Identifiable {

}
