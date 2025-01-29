//
//  ChatUser.swift
//  MASApplication
//
//  Created by Elliott Chen on 1/28/25.
//
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatUser {
    let uid, email: String
    var count: Int
    
    init(uid: String = "", email: String = "", count: Int = 0){
        self.uid = uid
        self.email = email
        self.count = count
    }
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.count = data["count"] as? Int ?? 0
    }
}



class UserViewModel : ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find Firebase uid"
            return
        }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to get current user: \(error)")
                self.errorMessage = "Failed to get current user: \(error)"
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            print(data)
            self.chatUser = ChatUser(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}
