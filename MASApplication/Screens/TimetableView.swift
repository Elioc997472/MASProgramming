//
//  Test.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/28/25.
//

import Foundation
import SwiftUI


import SwiftUI

struct TimeSlot: Identifiable {
    let id = UUID()
    let time: String
}

struct TimetableView: View {
    let timeSlots: [TimeSlot] = [
        TimeSlot(time: "8:00 AM"), TimeSlot(time: "8:30 AM"), TimeSlot(time: "9:00 AM"),
        TimeSlot(time: "9:30 AM"), TimeSlot(time: "10:00 AM"), TimeSlot(time: "10:30 AM"),
        TimeSlot(time: "11:00 AM"), TimeSlot(time: "11:30 AM"), TimeSlot(time: "12:00 PM"),
        TimeSlot(time: "12:30 PM"), TimeSlot(time: "1:00 PM"), TimeSlot(time: "1:30 PM"),
        TimeSlot(time: "2:00 PM"), TimeSlot(time: "2:30 PM"), TimeSlot(time: "3:00 PM"),
        TimeSlot(time: "3:30 PM"), TimeSlot(time: "4:00 PM"), TimeSlot(time: "4:30 PM"), TimeSlot(time: "5:00 PM"), TimeSlot(time: "5:30 PM"), TimeSlot(time: "6:00 PM"), TimeSlot(time: "6:30 PM"), TimeSlot(time: "7:00 PM"), TimeSlot(time: "7:30 PM"), TimeSlot(time: "8:00 PM"), TimeSlot(time: "8:30 PM"), TimeSlot(time: "9:00 PM"), TimeSlot(time: "9:30 PM"), TimeSlot(time: "10:00 PM"), TimeSlot(time: "10:30 PM"), TimeSlot(time: "11:00 PM"), TimeSlot(time: "11:30 PM"), TimeSlot(time: "12:00 AM")
    ]
    
    @Binding var selectedStartTime: String? // Start of booking
    @Binding var selectedEndTime: String?   // End of booking
    @Binding var currDate : Date
    @EnvironmentObject var bookingVM : BookingViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
//                Text("Washer Schedule")
//                    .padding(.bottom, 20)
//                    .font(.title2)
                ForEach(timeSlots.indices, id: \.self) { index in
                    let slot = timeSlots[index]
                    
                    HStack(alignment: .top, spacing: 5) {
                        VStack(alignment: .leading) {
                            Text(slot.time)
                                .frame(width: 80, alignment: .leading)
                                .padding(.leading, 3)
                                .padding(.top, 4)
                        }

                        Rectangle()
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundColor(isTimeSlotBlocked(slot.time) ? Color.red.opacity(0.3) :
                                isTimeSlotSelected(slot.time) ? Color.blue.opacity(0.3) : Color(uiColor: UIColor.systemBackground))
                            .overlay(
                                Rectangle().stroke(Color.black, lineWidth: isTimeSlotBlocked(slot.time) || isTimeSlotSelected(slot.time) ? 0 : 0.5)
                            )
                            .onTapGesture {
                                if !isTimeSlotBlocked(slot.time) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        toggleBooking(at: index)
                                    }
                                    print("Booking: \(selectedStartTime ?? "None") - \(selectedEndTime ?? "None")")
                                }
                            }
                            .padding(.trailing, 3)
                            .opacity(isTimeSlotSelected(slot.time) || isTimeSlotBlocked(slot.time) ? 1.0 : 0.6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding() // Add padding around the inner content
            
        }
    }
    
    /// Checks if a timeslot falls within the selected booking range
    private func isTimeSlotSelected(_ time: String) -> Bool {
        guard let start = selectedStartTime, let end = selectedEndTime else { return false }
        if let startIndex = timeSlots.firstIndex(where: { $0.time == start }),
           let endIndex = timeSlots.firstIndex(where: { $0.time == end }),
           let currentIndex = timeSlots.firstIndex(where: { $0.time == time }) {
            return currentIndex >= startIndex && currentIndex <= endIndex
        }
        return false
    }
    
    
    private func isTimeSlotBlocked(_ time: String) -> Bool {
        // New method to check overlap with otherBookings
        bookingVM.otherBookings.contains { booking in
            bookingVM.isTimeSlotWithinBooking(time: time, booking: booking, currDate: currDate)
        }
    }
    
    /// Handles toggling booking logic
    private func toggleBooking(at index: Int) {
        let availableSlots = timeSlots.count
        let nextIndex = index + 3 // 2 hours ahead (since each step is 30 min)
        
        let intendedSlotsBlocked = (index...nextIndex).contains { slotIndex in
            if slotIndex < availableSlots {
                return isTimeSlotBlocked(timeSlots[slotIndex].time)
            }
            return false
        }
        
        
        if intendedSlotsBlocked {
            if let start = selectedStartTime,
               let end = selectedEndTime,
               let startIndex = timeSlots.firstIndex(where: { $0.time == start }),
               let endIndex = timeSlots.firstIndex(where: { $0.time == end }),
               startIndex <= index && index <= endIndex {
                selectedStartTime = nil
                selectedEndTime = nil
                bookingVM.deleteBooking(for: currDate, userID: userVM.chatUser?.uid ?? "")
                return
            }
            for i in (0..<index).reversed() {
                let endIndex = i + 3
                if endIndex < availableSlots && !(i...endIndex).contains(where: { isTimeSlotBlocked(timeSlots[$0].time) }) {

                    selectedStartTime = timeSlots[i].time
                    selectedEndTime = timeSlots[endIndex].time
                    break
                }
            }

            if selectedStartTime == nil || selectedEndTime == nil {
                print("No suitable time slot found for booking.")
                return
            }
            
            if let startTime = bookingVM.parseTime(selectedStartTime, currDate), let endTime = bookingVM.parseTime(selectedEndTime, currDate) {
                print(startTime)
                print(endTime)
                let newBooking = Booking(
                    id: UUID().uuidString,
                    userID: userVM.chatUser?.uid ?? "",
                    startTime: startTime,
                    endTime: endTime
                )
                bookingVM.storeBooking(newBooking, userID: userVM.chatUser?.uid ?? "")
            }
        } else {
            if let start = selectedStartTime,
               let end = selectedEndTime,
               let startIndex = timeSlots.firstIndex(where: { $0.time == start }),
               let endIndex = timeSlots.firstIndex(where: { $0.time == end }),
               startIndex <= index && index <= endIndex {
                // If clicking inside the booked range, cancel the booking
                selectedStartTime = nil
                selectedEndTime = nil
                bookingVM.deleteBooking(for: currDate, userID: userVM.chatUser?.uid ?? "")
            } else {
                // Normal case: Book 2-hour block from clicked time
                if nextIndex < availableSlots {
                    selectedStartTime = timeSlots[index].time
                    selectedEndTime = timeSlots[nextIndex].time
                    print(selectedStartTime)
                    print(selectedEndTime)
                } else {
                    // If not enough time, fallback to last 2-hour block
                    selectedStartTime = timeSlots[availableSlots - 4].time
                    selectedEndTime = timeSlots[availableSlots - 1].time
                }
                
                if let startTime = bookingVM.parseTime(selectedStartTime, currDate), let endTime = bookingVM.parseTime(selectedEndTime, currDate) {
                    print(startTime)
                    print(endTime)
                    let newBooking = Booking(
                        id: UUID().uuidString,
                        userID: userVM.chatUser?.uid ?? "",
                        startTime: startTime,
                        endTime: endTime
                    )
                    bookingVM.storeBooking(newBooking, userID: userVM.chatUser?.uid ?? "")
                }
                
            }
        }
    }
}

extension Date {
    /// Checks if the date is between two other dates, inclusive of start and end
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        (self >= startDate) && (self <= endDate)
    }
}

extension BookingViewModel {
    func isTimeSlotWithinBooking(time: String, booking: Booking, currDate: Date) -> Bool {
        guard let timeDate = parseTime(time, currDate) else {
            return false
        }
        if (booking.startTime == nil) || (booking.endTime == nil) {
            return false
        } else {
            return timeDate.isBetween(booking.startTime!, and: booking.endTime!)
        }

    }
}

#Preview {
    TimetableView(selectedStartTime: .constant(nil), selectedEndTime: .constant(nil), currDate: .constant(Date()))
}



