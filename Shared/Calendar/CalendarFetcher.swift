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
    @Published var CalendarEvents = [TeamsEvent]()
    
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
        let utcFormatter = ISO8601DateFormatter()
        
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
                            output = "Acces token isn't right"
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
                    if let d = data {
                        do {
                            let teamsEvents = (try JSONDecoder().decode(TeamsEvents.self, from: d)).value
                            print("Result from Graph: \(teamsEvents.debugDescription)")
                            DispatchQueue.main.async { self.CalendarEvents = teamsEvents }
                        } catch {
                            print("Response:", response ?? "no response")
                            print("Couldn't deserialize result JSON with data \(String(decoding: data!, as: UTF8.self)) \n\nen met error: \(error)")
                            DispatchQueue.main.async { self.authManger.ErrorMsg = "Couldn't deserialize result JSON" }
                        }
                    }
                }
                
            }.resume()
        }
    }
}
