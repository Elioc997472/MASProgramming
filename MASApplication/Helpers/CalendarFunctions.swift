//
//  Calendar Functions.swift
//  ClubConnect
//
//  Created by Tejeshwar Natarajan on 9/10/24.
//

import Foundation


class DateVal : ObservableObject {
    // gets your current calendar format, whether you're using the Western calendar or some other format
    let calendar = Calendar.current
    // Date fromatter can help you extract values from the date object as a string
    let dateFormatter : DateFormatter = DateFormatter()

   // This is how we'll be getting the month and year as a string from the date object that we pass in.
    func monthYearString(_ date : Date) -> String {
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func monthYearDayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    // Tpo increment and decrement the current day and month
    func plusOneDay(_ date : Date) -> Date {
        return calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    func minusOneDay(_ date : Date) -> Date {
        return calendar.date(byAdding: .day, value: -1, to: date)!
    }
    
    func plusMonth(_ date : Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(_ date : Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    // This is to figure out how many days there are in the month
    func daysInMonth(_ date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    // We need to figure out the day of the week for the first day of the month to determine how many empty spaces we need to add to the calendar
    func dayOfWeek(_ date : Date) -> Int {
        let yearMonthComponent = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: yearMonthComponent)!
        let components = calendar.dateComponents([.weekday], from: firstDayOfMonth)
        // returns values from 1-7 denoting the day of week. Subtracting 1 normalizes the values to 0 for sunday and 6 for saturday. We do this so we can identify how many spaces we need on the calendar before the first day of the month
        return components.weekday! - 1
    }
    
    static func formatDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let daySuffix = getDaySuffix(for: date)
        let dateString = dateFormatter.string(from: date) + daySuffix
        
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: date).lowercased()
        
        return "\(dateString), \(timeString)"
    }

    static func getDaySuffix(for date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    
    static func earlierDate(_ date1: Date, _ date2: Date) -> Date {
        let calendar = Calendar.current
        
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        if components1.year! < components2.year! {
            return date1
        } else if components1.year! > components2.year! {
            return date2
        } else {
            if components1.month! < components2.month! {
                return date1
            } else if components1.month! > components2.month! {
                return date2
            } else {
                if components1.day! < components2.day! {
                    return date1
                } else {
                    return date2
                }
            }
        }
    }
    
    static func laterDate(_ date1: Date, _ date2: Date) -> Date {
        let calendar = Calendar.current
        
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        if components1.year! > components2.year! {
            return date1
        } else if components1.year! < components2.year! {
            return date2
        } else {
            if components1.month! > components2.month! {
                return date1
            } else if components1.month! < components2.month! {
                return date2
            } else {
                if components1.day! > components2.day! {
                    return date1
                } else {
                    return date2
                }
            }
        }
    }
    
    static func combineDateAndTime(datePart: Date, timePart: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePart)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timePart)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        return calendar.date(from: combinedComponents)
    }
    
    static func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust the date format as needed
        return dateFormatter.date(from: dateString)
    }
    
    
}

func testDateVal() {
    let dateVal = DateVal()
    let dateString = dateVal.monthYearString(Date())
    print(dateString)
}

