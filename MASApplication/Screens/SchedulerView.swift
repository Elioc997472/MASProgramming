//
//  SchedulerView.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/28/25.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct SchedulerView: View {
    @State var currDate = Date()
    @StateObject var dateVal = DateVal()
    @StateObject var userVM: UserViewModel
    @StateObject var bookingVM : BookingViewModel
    @State var shouldShowLogOutOptions = false
    
    init(userVM: UserViewModel) {
        self._userVM = StateObject(wrappedValue: userVM)
        self._bookingVM = StateObject(wrappedValue: BookingViewModel(userID: userVM.chatUser?.uid ?? ""))
    }
    
    private var startDateForCurrentView: Date {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currDate)?.start ?? currDate
        print(userVM.chatUser?.uid ?? "")
        print(bookingVM.userID)
        return startOfWeek
    }
    
    private var endDateForCurrentView: Date {
        let calendar = Calendar.current
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: currDate)?.end.addingTimeInterval(-1) ?? currDate
        return endOfWeek
    }
    
    @State private var selectedStartTime: String? // Start of booking
    @State private var selectedEndTime: String?
//    @State var chosenMonth: MonthType?
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        customNavBar
                        weekScrollView
                        days
                        calendarView
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: currDate) { _ in
                    Task {
                        let firstDate = startDateForCurrentView
                        let lastDate = endDateForCurrentView
                        print("Displaying week from \(firstDate) to \(lastDate)")
                    }
                }
//                Text("Washer Schedule")
//                    .font(.title)
                TimetableView(selectedStartTime: $selectedStartTime, selectedEndTime: $selectedEndTime, currDate: $currDate)
                    .environmentObject(bookingVM)
                    .environmentObject(userVM)
                    .onAppear {
                        bookingVM.fetchBookings(for: currDate, userID: userVM.chatUser?.uid ?? "") {
                            selectedStartTime = bookingVM.parseUserBooking().startTime
                            selectedEndTime = bookingVM.parseUserBooking().endTime
                        }
                    }
                    .onChange(of: currDate) { newDate in
                        bookingVM.fetchBookings(for: newDate, userID: userVM.chatUser?.uid ?? "") {
                            print(newDate)
                            selectedStartTime = bookingVM.parseUserBooking().startTime
                            selectedEndTime = bookingVM.parseUserBooking().endTime
                        }

                    }
                    .onChange(of: userVM.chatUser?.uid) {
                        bookingVM.fetchBookings(for: currDate, userID: userVM.chatUser?.uid ?? "") {
                            print("hi")
                            selectedStartTime = bookingVM.parseUserBooking().startTime
                            selectedEndTime = bookingVM.parseUserBooking().endTime
                        }

                    }
                    .background(RoundedRectangle(cornerRadius: 20) // Apply a rounded rectangle background
                                    .fill(Color(uiColor: UIColor.systemBackground)) // Fill the background with white color
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 0.5)
                                    ))
//                    TimetableView()
            }
        }
    }
    private var customNavBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                let email = userVM.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    userVM.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $userVM.isUserCurrentlyLoggedOut, onDismiss: nil){
            AuthView(didCompleteLoginProcess: {
                self.userVM.isUserCurrentlyLoggedOut = false
                self.userVM.fetchCurrentUser()
            })
        }
    }
    
    var weekScrollView: some View {
        HStack {
            Spacer()
            Button(action: {
                currDate = Calendar.current.date(byAdding: .day, value: -7, to: currDate) ?? currDate
            }, label: {
                Image(systemName: "arrowshape.left")
                    .imageScale(.large)
                    .font(Font.title.weight(.light))
                    .padding(5)
            })
            Text(dateVal.monthYearDayString(currDate))
                .font(Font.title.weight(.bold))
                .frame(maxWidth: .infinity)
            Button(action: {
                currDate = Calendar.current.date(byAdding: .day, value: 7, to: currDate) ?? currDate
            }, label: {
                Image(systemName: "arrowshape.right")
                    .imageScale(.large)
                    .font(Font.title.weight(.light))
                    .padding(5)
            })
            Spacer()
        }
    }
    
    var days: some View {
        HStack(spacing: 1) {
            ForEach(["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"], id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .padding(1)
            }
        }
    }
    
    var calendarView: some View {
        VStack(alignment: .center, spacing: 1) {
            let calendar = Calendar.current
            let daysOfWeek = (0..<7).compactMap { offset -> Date? in
                calendar.date(byAdding: .day, value: offset, to: startDateForCurrentView)
            }
            
            HStack(alignment: .top, spacing: 1) {
                ForEach(daysOfWeek, id: \.self) { date in
                    dayView(date: date)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
//        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func dayView(date: Date) -> some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding(4)
                .background(date == currDate ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(5)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture {
            currDate = date
        }
    }
    
    private var weekDateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startDate = startDateForCurrentView
        let endDate = endDateForCurrentView
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

#Preview {
    SchedulerView(userVM: UserViewModel())
}
