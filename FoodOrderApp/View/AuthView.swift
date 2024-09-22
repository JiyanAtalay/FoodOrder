//
//  ContentView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 13.08.2024.
//

import SwiftUI
import GoogleSignInSwift
import FirebaseCore
import FirebaseAuth
import Firebase
import GoogleSignIn

struct AuthView: View {
    
    let db = Firestore.firestore()
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showRs = false
    @State private var showAlert = false
    @State private var message = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                GroupBox {
                    HStack {
                        Text("E-mail :        ")
                        TextField("E-mail", text: $email)
                            .autocorrectionDisabled(true)
                    }
                }.frame(maxWidth: .infinity)
                
                GroupBox {
                    HStack {
                        Text("Password :  ")
                        SecureField("Password", text: $password)
                            .autocorrectionDisabled(true)
                    }
                }.frame(maxWidth: .infinity)
                
                GroupBox {
                    HStack {
                        GroupBox {
                            Button("Sign in") {
                                handleSignIn()
                            }
                        }
                        Spacer()
                        GoogleSignInButton(scheme: .dark, style: .icon, state: .normal) {
                            handleGoogleSignIn()
                        }
                        Spacer()
                        GroupBox {
                            Button("Sign up") {
                                handleSignUp()
                            }
                        }
                    }
                }
            }
            .padding()
            .fullScreenCover(isPresented: $showRs, content: {
                RestaurantsView()
            })
            .alert("Error", isPresented: $showAlert) {
                Button("OK!", role: .cancel) {
                    showAlert.toggle()
                    message = ""
                }
            } message: {
                Text(message)
            }
        }
    }
    
    private func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            message = email.isEmpty ? "Email is Empty!" : "Password is Empty!"
            showAlert = true
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                showAlert = true
            } else {
                showRs = true
            }
        }
    }
    
    private func handleSignUp() {
        Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
            if error != nil {
                message = error?.localizedDescription ?? "Error!"
                self.showAlert = true
            } else {
                let myUserDictionary: [String : Any] = ["useremail" : self.email, "useruidfromfirebase" : result!.user.uid]
                
                _ = self.db.collection("Users").addDocument(data: myUserDictionary, completion: { error in
                    if error != nil {
                        message = error?.localizedDescription ?? "Error!"
                        self.showAlert = true
                    }
                })
                
                self.showRs = true
            }
        }
    }
    
    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            _ = GoogleAuthProvider.credential(withIDToken: idToken,
                                              accessToken: user.accessToken.tokenString)
            
            // ...
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if error != nil {
                    message = error?.localizedDescription ?? "Error!"
                    self.showAlert = true
                } else {
                    
                    if let isNewUser = result?.additionalUserInfo?.isNewUser, isNewUser {
                        let myUserDictionary: [String : Any] = ["useremail" : user.profile?.email ?? "", "useruidfromfirebase" : result!.user.uid]
                                                                    
                        _ = self.db.collection("Users").addDocument(data: myUserDictionary) { error in
                            if let error = error {
                                message = error.localizedDescription
                                self.showAlert = true
                            }
                        }
                    }
                    self.showRs = true
                }
            }
            
            self.showRs = true
        }
    }
    
}

#Preview {
    AuthView()
}

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
