//
//  Moment+Until.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/15/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import SwiftMoment


// needed to dynamically select the bundle below
class MomentBundle: NSObject {}

extension Moment {
    
    public func isInThePast() -> Bool {
        return moment().intervalSince(self).seconds > 0
    }
    
    public func getComponents() -> DateComponents {
        return DateComponents(calendar: Calendar.current, timeZone: self.timeZone, year: self.year, month: self.month, day: self.day, hour: self.hour, minute: self.minute, second: self.second)
    }
    
//    public func humanTime(_ weeksOnly : Bool = false) -> String {
//        let timeDiffDuration = moment().intervalSince(self)
//        if timeDiffDuration.seconds < 0 {
//            return self.until(weeksOnly)
//        }
//        
//        return self.fromNow()
//    }
    
    public func from() -> String {
        let timeDiffDuration = moment().intervalSince(self)
        let deltaSeconds = timeDiffDuration.seconds
        
        var value: Int = 0
        
        if deltaSeconds < dayInSeconds {
            // Hours Ago
            value = Int(floor(deltaSeconds / hourInSeconds))
            return "Today"
            
        }
        else if deltaSeconds < (dayInSeconds * 2) {
            // Yesterday
            return "Yesterday"
            
        }
        else if deltaSeconds < weekInSeconds {
            // Days Ago
            value = Int(floor(deltaSeconds / dayInSeconds))
            return "\(value) days ago"
            
        }
        else if deltaSeconds < (weekInSeconds * 2) {
            // Last Week
            return "Last week"
            
        }
        else if deltaSeconds < monthInSeconds {
            // Weeks Ago
            value = Int(floor(deltaSeconds / weekInSeconds))
            return "\(value) weeks ago"
            
        }
        else if deltaSeconds < (dayInSeconds * 61) {
            // Last month
            return "Last month"
            
        }
        else if deltaSeconds < yearInSeconds {
            // Month Ago
            value = Int(floor(deltaSeconds / monthInSeconds))
            return "\(value) months ago"
            
        }
        else if deltaSeconds < (yearInSeconds * 2) {
            // Last Year
            return "Last year"
        }
        
        // Years Ago
        value = Int(floor(deltaSeconds / yearInSeconds))
        return "\(value) years ago"
    }
    
    public func until() -> String {
//        let beginningOfWeek = moment().startOf(.Weeks)
//        let beginningOfMonth = moment().startOf(.Months)

        let weekSeconds = moment().startOf(.Weeks).intervalSince(self).seconds * -1
        let monthSeconds = moment().startOf(.Months).intervalSince(self).seconds * -1
//        let deltaSeconds = timeDiffDuration.seconds * -1
        
        
        
        var value: Double!
        
        if weekSeconds < monthInSeconds {
            if weekSeconds < 0 && moment().intervalSince(self).seconds > 0 {
                return "Released"
            }
            
            if weekSeconds < weekInSeconds {
                return "This Week"
            }
            
            if weekSeconds < (weekInSeconds * 2) {
                return "Next week"
                
            }
            
            value = floor(weekSeconds / weekInSeconds)
            return "In \(Int(value)) weeks"
        }
        
        
        else if monthSeconds < (dayInSeconds * 61) {
            return "Next month"
            
        }
        else if monthSeconds < yearInSeconds {
            value = floor(monthSeconds / monthInSeconds)
            return "In \(Int(value)) months"
            
        }
        else if monthSeconds < (yearInSeconds * 2) {
            return "Next year"
        }

        value = floor(monthSeconds / yearInSeconds)

        return "In \(Int(value)) years"
    }
}
