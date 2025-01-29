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
                            .foregroundColor(isTimeSlotSelected(slot.time) ? Color.blue.opacity(0.3) : Color(uiColor: UIColor.systemBackground))
                            .overlay(
                                isTimeSlotSelected(slot.time) ?                                 Rectangle()
                                    .stroke(Color.black, lineWidth: 0) :
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    toggleBooking(at: index)
                                }
                                print("Booking: \(selectedStartTime ?? "None") - \(selectedEndTime ?? "None")")
                            }
                            .padding(.trailing, 3)
                            .opacity(isTimeSlotSelected(slot.time) ? 1.0 : 0.6) // Fade effect
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
    
    /// Handles toggling booking logic
    private func toggleBooking(at index: Int) {
        let availableSlots = timeSlots.count
        let nextIndex = index + 3 // 2 hours ahead (since each step is 30 min)

        if let start = selectedStartTime,
           let end = selectedEndTime,
           let startIndex = timeSlots.firstIndex(where: { $0.time == start }),
           let endIndex = timeSlots.firstIndex(where: { $0.time == end }),
           startIndex <= index && index <= endIndex {
            // If clicking inside the booked range, cancel the booking
            selectedStartTime = nil
            selectedEndTime = nil
            bookingVM.deleteBooking(for: currDate)
        } else {
            // Normal case: Book 2-hour block from clicked time
            if nextIndex < availableSlots {
                selectedStartTime = timeSlots[index].time
                selectedEndTime = timeSlots[nextIndex].time
            } else {
                // If not enough time, fallback to last 2-hour block
                selectedStartTime = timeSlots[availableSlots - 4].time
                selectedEndTime = timeSlots[availableSlots - 1].time
            }
            
            if let startTime = bookingVM.parseTime(selectedStartTime), let endTime = bookingVM.parseTime(selectedEndTime) {
                let newBooking = Booking(
                    id: UUID().uuidString,
                    userID: bookingVM.userID,
                    startTime: startTime,
                    endTime: endTime
                )
                bookingVM.storeBooking(newBooking)
            }
            
        }
    }
}

#Preview {
    TimetableView(selectedStartTime: .constant(nil), selectedEndTime: .constant(nil), currDate: .constant(Date()))
}



