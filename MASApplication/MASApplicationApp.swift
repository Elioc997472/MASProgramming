//
//  MASApplicationApp.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/27/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct MASApplicationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userVM = UserViewModel()
    

    var body: some Scene {
        WindowGroup {
            SchedulerView(userVM: userVM)
        }
    }
}
