//
//  CalendarFetcher.swift
//  snap
//
//  Created by Maarten Wittop Koning on 06/06/2021.
//

import Combine
import Foundation
import SwiftUI

public class CalendarFetcher: ObservableObject {
    @StateObject private var authManger: MsAuthManger
    @Published var CalendarEvents = [Event]()
    
    init(authManger: StateObject<MsAuthManger>) {
        _authManger = authManger
        self.authManger.TokenCallback = GetCalendar
        let volgendeweek = Date().addingTimeInterval(604800)
        if self.authManger.accessToken != "" {
            GetCalendar(volgendeweek)
        } else {
            print("AccessToken isn't there")
        }
        
    }
    
    func GetCalendar(_ EndDate: Date) -> Void {
        let today = Date()
        print("Calling graph Calendar")
        let utcFormatter = ISO8601DateFormatter()
        //eaxmple date 2021-05-27T11:43:27.144Z
        print(utcFormatter.string(from: today))
        
        var urlcomponents = URLComponents(string: "https://graph.microsoft.com")
        urlcomponents?.path = "/v1.0/me/calendarview"
        urlcomponents?.queryItems = [URLQueryItem(name: "startdatetime", value: utcFormatter.string(from: today)), URLQueryItem(name: "enddatetime", value: utcFormatter.string(from: EndDate))]
        let url = urlcomponents?.url
        if let theUrl = url {
            print("Making request with: \(theUrl.absoluteString)")
            var request = URLRequest(url: url!)
            print("Making reqeust with: \(authManger.accessToken)")
            request.setValue("Bearer \(authManger.accessToken)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: theUrl) {(data, response, error) in
                do {
                    if let d = data {
                        print(String(decoding: d, as: UTF8.self))
                        let decodedLists = try JSONDecoder().decode([Event].self, from: d)
                        DispatchQueue.main.async {
                            self.CalendarEvents = decodedLists
                        }
                    } else if let error = error {
                        
                        if let response = response as? HTTPURLResponse {
                            print("[ERROR] Er was geen data met het laden een url: \(theUrl) en met response: \(response) \n Met de error: \(error.localizedDescription) en data: \n \(String(decoding: data!, as: UTF8.self))")
                        } else {
                            print("[ERROR] Er was een terwijl de json werd geparsed: \(theUrl) Met de error: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    if let response = response as? HTTPURLResponse {
                        print("[ERROR] Er was geen data met het laden een url: \(theUrl) en met response: \(response) Met de error: \(error.localizedDescription) met data: \n \(String(decoding: data!, as: UTF8.self))")
                    } else {
                        print("[ERROR] Er was een terwijl de json werd geparsed: \(theUrl) met data \(String(decoding: data!, as: UTF8.self)) Met de error: \(error.localizedDescription)")
                    }
                }
            }.resume()
        }
    }
}
