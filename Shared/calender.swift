//
//  calender.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import Foundation
let calender = ["France", "Spain", "Sweden", "Norway", "Germany", "Finland", "Italy", "United Kingdom"]

struct Event: Codable, Identifiable, CustomStringConvertible {
    public var id: String
    public var title: String
    public var start: Date
    public var einde: Date
    public var tijd: Date {
        let formatter = DateFormatter()
        // TODO: Get duration door start en einde van el kaar af te halen
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let duration = formatter.dateFromString(date)
        return duration
    }
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case titel = "subject"
        case einde = "end"
    }
}
"""
TOOD: Graph json hier toevoegen
"""
