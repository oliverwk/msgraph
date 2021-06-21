//
//  GetMe.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import MSAL

extension MsAuthManger {
    
    func GetMe() {
        let url = URL(string: "https://graph.microsoft.com/v1.0/me")
        var request = URLRequest(url: url!)
        
        //Set the Authorization header. use Bearer + token
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        print("Making request to /me with token: \(self.accessToken)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                var output = ""
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        output =  NSLocalizedString("Acces token isn't right, please login", comment: "...")
                        self.signOut()
                        // Hier Dan get token callen
                    } else {
                        output = NSLocalizedString("Couldn't get graph result: \(error)", comment: "graph error bij /me")
                    }
                }
                DispatchQueue.main.async {
                    self.ErrorMsg = output
                    self.logedIn = false
                }
                return
                
            } else {
                if let d = data {
                    var result: Me
                    do {
                        result = try JSONDecoder().decode(Me.self, from: d)
                        print("Result from Graph: \(result)")
                        self.GetPhoto()
                        
                        // self.delegate?.DisplayError(msg: "Result from Graph: \(result))")
                        if result.displayName == "" {
                            print("No displayName")
                        }
                        
                        print("displayName:", result.displayName)
                        DispatchQueue.main.async {
                            self.logedIn = true
                            self.displayName = result.displayName
                        }
                    } catch {
                        print("Response:", response ?? "no response")
                        print("Couldn't deserialize result JSON with data \(String(decoding: data!, as: UTF8.self)):", error)
                        self.ErrorMsg = NSLocalizedString("Couldn't deserialize result JSON", comment: "bij /me")
                    }
                } else {
                    print("Er was geen data bij het reqeust naar de graph")
                    self.ErrorMsg = NSLocalizedString("Er was geen data bij het reqeust naar de graph", comment: "bij /me")
                }
            }
        }.resume()
    }
}
