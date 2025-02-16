//
//  NotificationManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/10/15.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore
import JWTKit

final class NotificationManager {
    static let instance: NotificationManager = NotificationManager()
    
    func sendPushNotification(fcmToken: String, Title: String, Body: String) {
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/glif-c9e53/messages:send") else {
            print("Invalid URL")
            return
        }
        
        let payload: [String: Any] = [
            "message": [
                "token": fcmToken,
                "notification": [
                    "title": Title,
                    "body": Body
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to create JSON data")
            return
        }
        
        // トークンを生成
        var token = ""
        do {
            token = try generateAccessToken()
            print("Access token: \(token)")
        } catch {
            print("Failed to generate access token: \(error)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    print("Response: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func generateAccessToken() throws -> String {
        // Replace with your actual service account private key and client email
        let privateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCz0LL8ZL3mqtCA\nZSC16RE9gSH3+TN612w95O8FT32QNLhFyy6uYguJ6ONdVUYhLUoMHPBW6Pdfn7Ar\ncfMejqe8PSDEk6+SyH6SLndlVJa3xdvdXmmf8pit2Bm46zvINqc7hdm7uxNW95UR\n1AE5kPYVsE0dRHw1oamNxrX0zQtb+kEDe8GXQhaQKfmL9zlQm/xxdTED0i39pxuH\nJfXU+a6MloX2C0sUYVmiXnVQSVaTyMBeLjuo5Zp2ZwXdeAH+e2Qc+As8licjZyqy\nzhQuZIhweC1hlknveu6KTlOX33QSC2tstydNR5+pwjc//M8RiqKOTXeSUxWRPhol\nx3e3UVItAgMBAAECggEADSavOIYWXNJTDoOW7rGy7kMisglaqloqvfoflc1YWx19\nTrQgtWX7/w72i2MgY8PKsx5uC4UytnPY8CHU4gAVT3n5tWGHHp6lodkJKB2Vf6+r\nuBc0IBvKQ94BakS2FMYT2WbIORKNGbgLgd12EM5D2UE8L+721ftStHOl54IURG/m\ndoNxnvb0F+sH84oTyy6S90I5H4S9Ot44BVr/RXOqGx5Yw/iFW1LiF54WB5z9kzwy\nVAPR2WJ73aUl6qfIeDMINQ4o5DcMB0bXhcRxXGIr7yqiCrJEUhxvFvDOKZEm3VTb\npRzGPEeRk3uUVNCwH8i94nLpjQvP6/Zt1z2JZVZQcQKBgQDDzr08KOrJivBaPdD/\nSxWZfTNhNZDCAOmQmQNjCheuCTIkxqvIgHRutI7TUX/dEqaqnYUNvXeRtWYRasH1\ny7rkkEPy4xOIBOoxY6rAFd4dhiK3Y6dPx6gs8zXC0Zxf8DvQ4HJbYiWjPQBzRqEK\nvGVCTqGV1B4xa5fnVx4Vkvq6uQKBgQDrF21uAcqZhLTjoUC1dF/O5P1dc8UG7A/F\nuJdYoedJVKlUEurUJrDD8vAP7YRTfdoM1vgbnbOPT9rxISBllrLW3oij+jITfV4x\nr4/CriZRNRguKlqGYSUFyrHszj0lG7XclM9EukPGcWm66LPecT8Z86m1t9Tc5TpJ\nU/ykK+uJFQKBgQCMIxJcVAx1YfLTIxrJG7vBtlFnaSbJMk33Jwu9fiOkcwBoQagA\nP68U7DSsGNAiMI8H3OS1CLzik6kRHg7jE4QWwQlgdBQubRYPcv1prDzjdHS0O6Yq\n+wHp6ca4P7xjDVRCEeDGdl/pjGceGZZ4UI1H/262BLH3PMHi1/64AhFgQQKBgFVO\nYfoKEl9UpWL4L4fom59yvnF7weH6JNsFWX3i+g9E9lC4sJedFoV0ESJmeJ7nSwlf\ntBYpSm/VdUgMUjoqzehkRcbi0er6kgSLhSoKkYLkNksCOWkLtSh93cRlLhDaFkrd\ngLyarl9C5i/ZovMzuscLAOkctNQXJehX3pQgD87lAoGAXJhTk62X0GtzYgzOM2YY\n4hy/8wVE8u+pmkNVEwX1iZAIn5nr/T+4jzt9emVTZvoPiQWCH4G2mWfY/N2P+MPu\nViPOiwY8kAylAnjwg26mE9yvyYmw0/m9SNl3+ZnJQcPJw9x08i/aFCsNgcMofNMd\nRzuelt/lt+RvlQa7G0p0fac=\n-----END PRIVATE KEY-----\n"
        let clientEmail = "glif-c9e53@appspot.gserviceaccount.com"
        
        // Initialize JWTSigner for RS256 (RSA SHA-256)
        let signers = JWTSigner.rs256(key: try .private(pem: privateKey))
        
        let payload = PayloadData(
            iss: clientEmail,
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            aud: "https://oauth2.googleapis.com/token",
            exp: Date().addingTimeInterval(3600), // 1 hour expiration
            iat: Date()
        )
        
        // Generate JWT token
        let jwt: String
        do {
            jwt = try signers.sign(payload)
        } catch {
            throw error
        }
        
        // Exchange the JWT for an access token
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        request.httpBody = body.data(using: .utf8)
        
        let semaphore = DispatchSemaphore(value: 0)
        var accessToken: String?
        var requestError: Error?
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                requestError = error
                print("Error requesting access token: \(error)")
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["access_token"] as? String {
                        accessToken = token
                    } else {
                        print("Invalid response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    }
                } catch {
                    requestError = error
                    print("Error parsing response data: \(error)")
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        if let error = requestError {
            throw error
        }
        
        // Return the access token or handle error if nil
        guard let token = accessToken else {
            fatalError("Failed to retrieve access token")
        }
        
        return token
    }
}

struct PayloadData: JWTPayload {
    let iss: String
    let scope: String
    let aud: String
    let exp: Date
    let iat: Date
    
    // Conformance to JWTPayload requires this function
    func verify(using signer: JWTSigner) throws {
        // Add custom verification logic if needed
    }
}

