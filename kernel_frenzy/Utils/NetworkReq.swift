//
//  NetworkReq.swift
//  kernel_frenzy
//
//  Created by admin49 on 14/02/25.
//

import Foundation

class Post {
    init() {}
    
    func makeGetRequest() {
            let urlString = "http://10.3.251.71:8000/"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
        URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(
                        with: data, options: [])
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? "Unable to decode JSON"
                    print(jsonString)

                } catch {
                    print("JSON decoding error: \(error)")
                }
            }.resume()
        }
    
    func uploadFile() async {
        
    }
    

    func saveUserInfo(_ id: UUID, _ name: String, _ email: String) async {
        let urlString = "http://10.3.251.71:8000/userinfo"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let userInfo = UserInfo(id: id, name: name, email: email)

        do {
            let jsonData = try JSONEncoder().encode(userInfo)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode JSON: \(error)")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("User info added successfully")
            } else {
                print("Failed with status code: \(httpResponse.statusCode)")
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Response: \(jsonResponse)")
            }
            
        } catch {
            print("Request failed: \(error)")
        }
    }
}
