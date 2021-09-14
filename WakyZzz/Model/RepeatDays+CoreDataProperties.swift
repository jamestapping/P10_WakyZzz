//
//  RepeatDays+CoreDataProperties.swift
//  WakyZzz
//
//  Created by James Tapping on 06/09/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension RepeatDays {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepeatDays> {
        return NSFetchRequest<RepeatDays>(entityName: "RepeatDays")
    }

    @NSManaged public var friday: Bool
    @NSManaged public var monday: Bool
    @NSManaged public var saturday: Bool
    @NSManaged public var sunday: Bool
    @NSManaged public var thursday: Bool
    @NSManaged public var tuesday: Bool
    @NSManaged public var wednesday: Bool
    @NSManaged public var managedAlarm: ManagedAlarm?

}

extension RepeatDays : Identifiable {

}
