//
//  ContentView.swift
//  CrudSwiftUIApp
//
//  Created by ipeerless on 12/02/2024.
//

import SwiftUI
import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

class APIService {
    let baseURL = "https://jsonplaceholder.typicode.com/users"
        
    func getUsers(completion: @escaping([User]) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let users = try? JSONDecoder().decode([User].self, from: data)
                completion(users ?? [])
            } else {
                completion([])
                
            }
        }.resume()
    }
    
    func createUser(user: User, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 201)
            } else {
                completion(false)
            }
        }.resume()
        
        
    }
    
    func updateUser(user: User, completion: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/\(user.id)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    func deleteUser(user: User, completion: @escaping (Bool) -> Void) {
           guard let url = URL(string: "\(baseURL)/\(user.id)") else {
               completion(false)
               return
           }
           
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 204)
            } else {
                completion(false)
                
            }
        }.resume()
    
    }
}


struct CrudViewWithCompletion: View {
@State private var users: [User] = []
        
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
                .onAppear {
                    APIService().getUsers { users in
                        self.users = users
                    }
                }
                
                Button("Create User") {
                    let newUser = User(id: 11, name: "John", email: "john@example.com")
                    APIService().createUser(user: newUser) { success in
                        if success {
                            print("User created successfully")
                        } else {
                            print("Failed to create user")
                        }
                    }
                }
                
                Button("Update User") {
                    let updatedUser = User(id: 1, name: "John Doe", email: "john@example.com")
                    APIService().updateUser(user: updatedUser) { success in
                        if success {
                            print("User updated successfully")
                        } else {
                            print("Failed to update user")
                        }
                    }
                }
                
                Button("Delete User") {
                    let userToDelete = User(id: 1, name: "John Doe", email: "john@example.com")
                    APIService().deleteUser(user: userToDelete) { success in
                        if success {
                            print("User deleted successfully")
                        } else {
                            print("Failed to delete user")
                        }
                    }
                }
            }
            
        }
    }
#Preview {
    CrudViewWithCompletion()
}
