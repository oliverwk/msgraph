//
//  Me.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import Foundation

struct Me: Codable {
    let odataContext: String
    let displayName, surname, givenName, id: String
    let userPrincipalName: String
    let businessPhones: [JSONAny]
    let jobTitle, mail, mobilePhone, officeLocation: JSONNull?
    let preferredLanguage: JSONNull?

    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case displayName, surname, givenName, id, userPrincipalName, businessPhones, jobTitle, mail, mobilePhone, officeLocation, preferredLanguage
    }
}
