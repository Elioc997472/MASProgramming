//
//  Booking.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/28/25.
//

import Foundation

struct Booking : Codable {
    var id : String
    var userID : String
    var startTime : Date?
    var endTime : Date?
    
    enum CodingKeys: String, CodingKey {
        case id, userID, startTime, endTime
    }
}


