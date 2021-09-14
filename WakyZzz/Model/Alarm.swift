//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation 

class Alarm: Equatable {
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        
        return true
    }
    
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var uuid:UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    // time in minutes from 00:00 / 8 * 3600 minutes gives a defualt time of 8:00 am
    
    var time = 8 * 3600
    var repeatDays = [false, false, false, false, false, false, false]
    var enabled = true
    var snoozeCount = 0
    
    var alarmDate: Date? {
        let date = Date()
        let calendar = Calendar.current
        let h = time/3600
        let m = time/60 - h * 60
        
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        components.hour = h
        components.minute = m
        
        return calendar.date(from: components)
    }
    
    var scheduleDays:[Int]  {
    
        var tmpArray = [Int]()
        
        // 1 is Sunday
        // 2 is Monday
        // 3 is Tuesday
        // 4 is wednesday
        // 5 is Thursday
        // 6 is Friday
        // 7 is Saturday
        
        // Need an array of int
        
        for (i,repeatDay) in repeatDays.enumerated() {

            if repeatDay {

                tmpArray.append(i + 1)
            }

        }
    return tmpArray
        
        
    }
    
    var caption: String {        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.alarmDate!)
    }
    
    var repeating: String {
        var captions = [String]()
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] {
                captions.append(Alarm.daysOfWeek[i])
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    func setTime(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        time = components.hour! * 3600 + components.minute! * 60        
    }

}
