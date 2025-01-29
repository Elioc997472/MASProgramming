//
//  Day Component.swift
//  ClubConnect
//
//  Created by Tejeshwar Natarajan on 9/10/24.
//
import Foundation
import SwiftUI

struct DayStruct {
//    var monthType : MonthType
    var day : Int
    
    func date(currDate: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month], from: currDate)
        
//        switch monthType {
//        case .Previous:
//            components.month = (components.month ?? 1) - 1
//        case .Current:
//            // Keep the current month as is
//            break
//        case .Next:
//            components.month = (components.month ?? 1) + 1
//        }
        
        components.day = day
        
        // Ensure month doesn't go out of bounds
        return Calendar.current.date(from: components)
    }
}

//enum MonthType {
//    case Previous
//    case Current
//    case Next
//}


struct DayComponent: View {
    
    @EnvironmentObject var dateVal : DateVal
    let daysInMonth : Int
    let startingSpaces : Int
    let count : Int
    let daysInPrevMonth : Int
    let referenceDate : Date
//    var eventVM : EventViewModel
    @Binding var chooseDateNum : Int?
//    @Binding var chooseMonthNum : MonthType?
    
    var body: some View {
            Text(String(calculateDay().day))
//                   .foregroundColor(calculateDay().monthType == .Current ? .primary : .gray)
                   .padding(5)
                   .background() {
                       if isToday {
                           Circle()
                               .fill(Color.red.opacity(0.5))
                       }
                   }
       }
    
    
    // Function to calculate what day should be represented on a position in the calendar
    func calculateDay() -> DayStruct {
        let startPos = startingSpaces == 0 ? startingSpaces + 7 : startingSpaces
        if count <= startPos {
            let day = daysInPrevMonth + count - startPos
            return DayStruct(day: day)
        } else if (count - startPos > daysInMonth) {
            let day = count - startPos - daysInMonth
            return DayStruct(day: day)
        }
        let day = count - startPos
        return DayStruct(day: day)
    }
    
    private var isToday: Bool {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        
        return calculateDay().day == day && isDateInCurrentMonth()
    }
    
    private func isDateInCurrentMonth() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        
        return calendar.isDate(referenceDate, equalTo: currentDate, toGranularity: .month)
    }
}
