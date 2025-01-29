//
//  BookingViewModel.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/28/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct DayMonthYear: Hashable {
    let day: Int
    let month: Int
    let year: Int
    
    init(date: Date) {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        self.day = components.day ?? 0
        self.month = components.month ?? 0
        self.year = components.year ?? 0
    }
    
    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
}

class BookingViewModel : ObservableObject {
    var userID : String
    @Published var userBookings = [Booking]()
    @Published var otherBookings = [Booking]()
    private let db = Firestore.firestore()
    let calendar = Calendar.current
    
    init(userID: String) {
        self.userID = userID
    }


    func fetchBookings(for date: Date, userID: String, completion: @escaping () -> Void) {
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        print("dayStart:", dayStart)
        print("dayEnd:", dayEnd)

        let bookingsRef = db.collection("bookings")
        bookingsRef
            .whereField("startTime", isGreaterThanOrEqualTo: dayStart)
            .whereField("endTime", isLessThan: dayEnd)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                print(userID)
                var fetchedUserBookings = [Booking]()
                var fetchedOtherBookings = [Booking]()
                for document in querySnapshot!.documents {
                    do {
                        var booking = try document.data(as: Booking.self)
                        booking.id = document.documentID
                        print(booking.id)
                        print(booking.userID)
                        print(self.userID)
                        if booking.userID == userID {
                            fetchedUserBookings.append(booking)
                        } else {
                            fetchedOtherBookings.append(booking)
                        }
                    } catch let error {
                        print("Error decoding booking: \(error)")
                    }
                }

                DispatchQueue.main.async {
                    self.userBookings = fetchedUserBookings
                    self.otherBookings = fetchedOtherBookings
                    completion()
                }
            }
        }
    
    func storeBooking(_ booking: Booking, userID: String) {
        guard let startTime = booking.startTime else {
            print("Booking must have a valid start time")
            return
        }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startTime)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let bookingsRef = db.collection("bookings")
        
        // Step 1: Query and delete existing bookings for the same day
        bookingsRef
            .whereField("userID", isEqualTo: userID)
            .whereField("startTime", isGreaterThanOrEqualTo: startOfDay)
            .whereField("startTime", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                // Delete all documents for the day
                for document in documents {
                    bookingsRef.document(document.documentID).delete() { error in
                        if let error = error {
                            print("Error removing document: \(document.documentID) - \(error.localizedDescription)")
                        } else {
                            print("Successfully removed document: \(document.documentID)")
                        }
                    }
                }

                // Step 2: Add the new booking after deletions
                let bookingData: [String: Any] = [
                    "id": booking.id,
                    "userID": userID,
                    "startTime": booking.startTime ?? NSNull(),
                    "endTime": booking.endTime ?? NSNull()
                ]
                
                bookingsRef.document(booking.id).setData(bookingData) { error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully added!")
                    }
                }
            }
    }
    
//    func deleteBooking(_ bookingId: String) {
//        let db = Firestore.firestore()
//        let bookingsRef = db.collection("bookings")
//        
//        bookingsRef.document(bookingId).getDocument { (document, error) in
//            if let document = document, document.exists {
//                bookingsRef.document(bookingId).delete() { error in
//                    if let error = error {
//                        print("Error removing document: \(error.localizedDescription)")
//                    } else {
//                        print("Document successfully removed!")
//                    }
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
    // Deletes user booking during a given day
    func deleteBooking(for date: Date, userID: String) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let bookingsRef = db.collection("bookings")
        
        // Query to find all bookings for the user within the given date range
        bookingsRef
            .whereField("userID", isEqualTo: userID)
            .whereField("startTime", isGreaterThanOrEqualTo: startOfDay)
            .whereField("startTime", isLessThan: endOfDay)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("No documents found")
                    return
                }
                
                // Deleting each booking document found for the user on the given date
                for document in querySnapshot.documents {
                    bookingsRef.document(document.documentID).delete() { error in
                        if let error = error {
                            print("Error removing document: \(error.localizedDescription)")
                        } else {
                            print("Document successfully removed: \(document.documentID)")
                        }
                    }
                }
            }
    }
    
    // Function to parse the user's booking and format the start and end times
    func parseUserBooking() -> (startTime: String?, endTime: String?) {
        guard let booking = userBookings.first else { return (nil, nil) }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let startTime = booking.startTime.map { formatter.string(from: $0) }
        let endTime = booking.endTime.map { formatter.string(from: $0) }

        return (startTime, endTime)
    }
    
    func parseTime(_ time: String?, _ day: Date) -> Date? {
        guard let timeString = time else { return nil }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"  // Format for the time part
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        let calendar = Calendar.current

        // Extract the time component from the string
        guard let timePart = timeFormatter.date(from: timeString) else { return nil }

        // Extract date components from the given day
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)

        // Extract time components from the parsed time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePart)

        // Combine date and time components
        var components = DateComponents()
        components.year = dayComponents.year
        components.month = dayComponents.month
        components.day = dayComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        // Generate the final date combining both the date and time parts
        return calendar.date(from: components)
    }
}
