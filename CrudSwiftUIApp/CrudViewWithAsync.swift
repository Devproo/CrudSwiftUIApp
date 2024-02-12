//
//  ContentView.swift
//  CrudSwiftUIApp
//
//  Created by ipeerless on 12/02/2024.
//

import SwiftUI
import Foundation

struct User1: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
}

class  ApiManager {
    let mainUrl = "https://jsonplaceholder.typicode.com/users"
    
    func getUsers() async throws -> [User1] {
        guard let url = URL(string: mainUrl) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let users = try JSONDecoder().decode([User1].self, from: data)
        return users
    }
    
    func createUser(user: User1) async throws -> Bool {
        guard let url = URL(string: mainUrl) else {
            throw NSError(domain: "Invalid Response ", code: 0, userInfo: nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(user)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse  = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        return httpResponse.statusCode == 201
    }
    
    func updateUser(user: User1) async throws -> Bool {
        guard let url = URL(string: "\(mainUrl)/\(user.id)") else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try JSONEncoder().encode(user)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        return httpResponse.statusCode == 200
    }
    
    func deleteUser(user: User1) async throws -> Bool {
        guard let url = URL(string: "\(mainUrl)/\(user.id)") else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response ) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else  {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        return httpResponse.statusCode == 200
    }
    
}


struct CrudViewWithAsync: View {
    @State private var users: [User1] = []
    var body: some View {
        VStack {
            List(users, id: \.id) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .task {
                do {
                    users = try await ApiManager().getUsers()
                } catch {
                    print("Failed to fetch users: \(error)")
                }
            }
            
            Button("Create User") {
                Task {
                    let newUser = User1(id: 1, name: "Adam", email: "adam@self.com")
                    do {
                        let success = try await ApiManager().createUser(user: newUser)
                        if success {
                            print("User created successfully")
                        } else {
                            print("Failed to create user")
                        }
                    } catch {
                        print("Failed to create user: \(error)")
                    }
                }
            }
            Button("Update User") {
                let updatedUser = User1(id: 1, name: "Adam", email: "adam@self.com")
                Task {
                    do {
                        let success = try await ApiManager().updateUser(user: updatedUser)
                        if success {
                            print("User updated successfully")
                        } else {
                            print("Failed to update user")
                        }
                    } catch {
                        print("Failed to create user: \(error)")
                    }
                }
            }
            Button("Delete User") {
                let userToDelete = User1(id: 1, name: "Adam", email: "adam@self.com")
                Task {
                    do {
                        let success = try await ApiManager().deleteUser(user: userToDelete)
                        if success {
                            print("User deleted successfully")
                        } else {
                            print("Failed to delete user")
                        }
                        
                        
                    } catch {
                        print("Failed to delete user: \(error)")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    CrudViewWithAsync()
}
