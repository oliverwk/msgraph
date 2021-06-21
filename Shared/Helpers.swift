//
//  Helpers.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import Foundation

extension Date {
    init(string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //   From Spacex API    2020-10-24T11:31:00-04:00
        //   From Example       13-03-2020 13:37:00 +0100
        let TheDate = string.split(usingRegex: "-\\d\\d:\\d\\d")[0]
        print("current date: \(string) current dateComponetns: \(String(describing: formatter.date(from: TheDate)))")
        print("TheDate:", string.split(usingRegex: "-\\d\\d:\\d\\d")[0])
        let UnixEpoch = formatter.date(from: TheDate)?.timeIntervalSince1970 ?? 1623746133.0
        self.init(timeIntervalSince1970: UnixEpoch)
    }
    
    public func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
//        formatter.locale = Locale(identifier: "nl_NL")

        let dateTimeString = formatter.string(from: self)
        return dateTimeString
    }
}

extension String {
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }
}
