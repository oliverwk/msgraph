//
//  ErrorDataGraph.swift
//  snap (iOS)
//
//  Created by Olivier Wittop Koning on 07/06/2021.
//
import Foundation

// MARK: - ErrorDataGraph
struct ErrorDataGraph: Codable {
    let error: MsError
}

// MARK: - Error
struct MsError: Codable {
    let code, message: String
    let innerError: InnerError
}

// MARK: - InnerError
struct InnerError: Codable {
    let date, requestID, clientRequestID: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case requestID = "request-id"
        case clientRequestID = "client-request-id"
    }
}

