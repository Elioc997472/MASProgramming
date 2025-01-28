//
//  LearningApp.swift
//  Learning
//
//  Created by Elliott Chen on 1/26/25.
//

import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            ScrumsView(scrums: DailyScrum.sampleData)
        }
    }
}
