//
//  Booking.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/28/25.
//

import Foundation

struct Booking : Identifiable, Codable, Equatable, Hashable {
    let id : String
    var userID : String
    var startTime : Date?
    var endTime : Date?
}


