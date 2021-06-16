//
//  Event.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//
import Foundation

struct Event: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var description: String
    public var start: Date
    public var location: String
}
