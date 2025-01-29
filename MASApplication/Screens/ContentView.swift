//
//  ContentView.swift
//  MASApplication
//
//  Created by Tejeshwar Natarajan on 1/27/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct AuthView: View {
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label:
                            Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode{
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
                        }
                    }

                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                        
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(Color.white)
                                .padding(.vertical, 10)
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(Color.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to log in user", err)
                self.loginStatusMessage = "Failed to log in user: \(err)"
                return
            }
            
            print("Succesfully logged in user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in user: \(result?.user.uid ?? "")"
            self.didCompleteLoginProcess()
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Succesfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            //self.persistImageToStorage()
            self.storeUserInformation()
            self.didCompleteLoginProcess()
        }
    }
    
    private func storeUserInformation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "count": 0] as [String : Any]
        Firestore.firestore().collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
        print("Success")
        }
        
    }
//    private func persistImageToStorage() {
//        let fileName = UUID().uuidString
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let ref = Storage.storage().reference(withPath: uid)
//        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
//        ref.putData(imageData, metadata: nil) { metadata, err in
//            if let err = err {
//                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
//                return
//            }
//        }
//        ref.downloadURL { url, err in
//            if let err = err {                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
//                return
//            }
//            self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
//            print(url?.absoluteString)
//        }
//    }
}

#Preview {
    AuthView(didCompleteLoginProcess: {
        
    })
}
