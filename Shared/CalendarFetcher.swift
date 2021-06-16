//
//  CalendarFetcher.swift
//  snap
//
//  Created by Olivier Wittop Koning on 06/06/2021.
//

import Combine
import Foundation
import SwiftUI

public class CalendarFetcher: ObservableObject {
    @StateObject private var authManger: MsAuthManger
    @Published var CalendarEvents = [Event]()
    
    init(authManger: StateObject<MsAuthManger>) {
        _authManger = authManger
        self.authManger.CalendarTokenCallback = GetCalendar
        let volgendeweek = Date().addingTimeInterval(604800)
        let _ = self.authManger.AccessTokenCahnged.sink { _ in
            print("AccessToken is now \(self.$authManger.accessToken)")
            self.GetCalendar(volgendeweek)
        }
        
        if self.authManger.accessToken != "" {
            GetCalendar(volgendeweek)
        } else {
            print("AccessToken isn't there")
        }
        
    }
    
    func GetCalendar(_ datum: Date) {
        
        let EndDate = Date().addingTimeInterval(604800)
        let today = Date()
        // Specify the Graph API endpoint
        let utcFormatter = ISO8601DateFormatter()
        print(utcFormatter.string(from: today))
        
        var urlcomponents = URLComponents(string: "https://graph.microsoft.com")
        urlcomponents?.path = "/v1.0/me/calendarview"
        urlcomponents?.queryItems = [URLQueryItem(name: "startdatetime", value: utcFormatter.string(from: today)), URLQueryItem(name: "enddatetime", value: utcFormatter.string(from: EndDate))]
        let url = urlcomponents?.url
        if let theUrl = url {
            
            //let url = URL(string: "https://graph.microsoft.com/v1.0/me/calendarview?startdatetime=2021-06-07T15:26:05Z&enddatetime=2021-06-14T15:26:05Z")
            var request = URLRequest(url: theUrl)
            
            request.setValue("Bearer \(self.authManger.accessToken)", forHTTPHeaderField: "Authorization")
            print("Making request to /calender with token: \(self.authManger.accessToken)")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    var output = ""
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 403 {
                            output = "Acces token isn't good"
                            // Hier Dan get token callen
                        } else {
                            output = "Couldn't get graph result: \(error)"
                        }
                    }
                    DispatchQueue.main.async {
                        self.authManger.ErrorMsg = output
                        self.authManger.logedIn = false
                    }
                    return
                    
                } else {
                    var result: Any
                    do {
                        result = try JSONSerialization.jsonObject(with: data!, options: [])
                        print("Result from Graph: \(result)")
                        // DispatchQueue.main.async { self.authManger.ErrorMsg = "Result from Graph: \(result))" }
                        let teamsEvents = (try JSONDecoder().decode(TeamsEvents.self, from: data!)).value
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssssss"
                        // self.CalendarEvents = teamsEvents
                        DispatchQueue.main.async {
                            for event in teamsEvents {
                                self.CalendarEvents.append(Event(name: event.subject, description: event.bodyPreview, start: dateFormatter.date(from: event.start.dateTime)!, location: event.location.displayName ?? "Geen Location"))
                            }
                        }
                    } catch {
                        print("Response:", response ?? "no response")
                        print("Couldn't deserialize result JSON with data \(String(decoding: data!, as: UTF8.self)) \n\nen met error: \(error)")
                        DispatchQueue.main.async { self.authManger.ErrorMsg = "Couldn't deserialize result JSON" }
                    }
                }
                
            }.resume()
        }
    }
}
