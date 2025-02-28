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

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
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
                let jsonData = try JSONSerialization.data(
                    withJSONObject: jsonObject, options: .prettyPrinted)
                let jsonString =
                    String(data: jsonData, encoding: .utf8)
                    ?? "Unable to decode JSON"
                print(jsonString)

            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }

    func uploadFile(_ fileUrl: URL) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("User ID not found in UserDefaults")
            return
        }

        guard
            let serverURL = URL(
                string: "https://kernel-frenzy.onrender.com/uploadcsv")
        else {
            print("Invalid URL")
            return
        }

        guard let fileData = try? Data(contentsOf: fileUrl) else {
            print("Failed to read file data")
            return
        }

        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(
                using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileUrl.lastPathComponent)\"\r\n"
                .data(using: .utf8)!)

        let fileExtension = fileUrl.pathExtension.lowercased()
        let contentType: String
        switch fileExtension {
        case "pdf":
            contentType = "application/pdf"
        case "csv":
            contentType = "text/csv"
        case "txt":
            contentType = "text/plain"
        default:
            contentType = "application/octet-stream"
        }
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        } catch {
            throw error
        }
    }

    func getallFile() async throws -> [FileItem] {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            throw URLError(.userAuthenticationRequired)
        }

        let urlString = "https://kernel-frenzy.onrender.com/getcsv/" + userId
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(APIResponse.self, from: data)
        return apiResponse.data
    }

    func deleteFile(_ fileName: String) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            throw URLError(.userAuthenticationRequired)
        }

        guard
            let url = NetworkURL.baseURL.appendingPathComponent("deletecsv").appendingPathComponent(userId)
                .appendingPathComponent(fileName) as URL?
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(
                for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.cannotRemoveFile)  // Customize error if needed
            }

            print("✅ File deleted successfully: \(fileName)")

        } catch {
            print("❌ Error deleting file: \(error.localizedDescription)")
            throw error
        }

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
            let (data, response) = try await URLSession.shared.data(
                for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("User info added successfully")
            } else {
                print("Failed with status code: \(httpResponse.statusCode)")
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(
                with: data, options: [])
            {
                print("Response: \(jsonResponse)")
            }

        } catch {
            print("Request failed: \(error)")
        }
    }
}
