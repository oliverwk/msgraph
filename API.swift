// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class LaunchListQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
        """
    query LaunchList {
      launchesPast(limit: 15) {
        __typename
        mission_name
        id
        details
        launch_date_local
        launch_site {
          __typename
          site_name_long
        }
        links {
          __typename
          video_link
          flickr_images
        }
        rocket {
          __typename
          rocket_name
        }
      }
    }
    """
    
    public let operationName: String = "LaunchList"
    
    public init() {
    }
    
    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Query"]
        
        public static var selections: [GraphQLSelection] {
            return [
                GraphQLField("launchesPast", arguments: ["limit": 15], type: .list(.object(LaunchesPast.selections))),
            ]
        }
        
        public private(set) var resultMap: ResultMap
        
        public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
        }
        
        public init(launchesPast: [LaunchesPast?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Query", "launchesPast": launchesPast.flatMap { (value: [LaunchesPast?]) -> [ResultMap?] in value.map { (value: LaunchesPast?) -> ResultMap? in value.flatMap { (value: LaunchesPast) -> ResultMap in value.resultMap } } }])
        }
        
        public var launchesPast: [LaunchesPast?]? {
            get {
                return (resultMap["launchesPast"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [LaunchesPast?] in value.map { (value: ResultMap?) -> LaunchesPast? in value.flatMap { (value: ResultMap) -> LaunchesPast in LaunchesPast(unsafeResultMap: value) } } }
            }
            set {
                resultMap.updateValue(newValue.flatMap { (value: [LaunchesPast?]) -> [ResultMap?] in value.map { (value: LaunchesPast?) -> ResultMap? in value.flatMap { (value: LaunchesPast) -> ResultMap in value.resultMap } } }, forKey: "launchesPast")
            }
        }
        
        public struct LaunchesPast: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Launch"]
            
            public static var selections: [GraphQLSelection] {
                return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("mission_name", type: .scalar(String.self)),
                    GraphQLField("id", type: .scalar(GraphQLID.self)),
                    GraphQLField("details", type: .scalar(String.self)),
                    GraphQLField("launch_date_local", type: .scalar(String.self)),
                    GraphQLField("launch_site", type: .object(LaunchSite.selections)),
                    GraphQLField("links", type: .object(Link.selections)),
                    GraphQLField("rocket", type: .object(Rocket.selections)),
                ]
            }
            
            public private(set) var resultMap: ResultMap
            
            public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
            }
            
            public init(missionName: String? = nil, id: GraphQLID? = nil, details: String? = nil, launchDateLocal: String? = nil, launchSite: LaunchSite? = nil, links: Link? = nil, rocket: Rocket? = nil) {
                self.init(unsafeResultMap: ["__typename": "Launch", "mission_name": missionName, "id": id, "details": details, "launch_date_local": launchDateLocal, "launch_site": launchSite.flatMap { (value: LaunchSite) -> ResultMap in value.resultMap }, "links": links.flatMap { (value: Link) -> ResultMap in value.resultMap }, "rocket": rocket.flatMap { (value: Rocket) -> ResultMap in value.resultMap }])
            }
            
            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }
            
            public var missionName: String? {
                get {
                    return resultMap["mission_name"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "mission_name")
                }
            }
            
            public var id: GraphQLID? {
                get {
                    return resultMap["id"] as? GraphQLID
                }
                set {
                    resultMap.updateValue(newValue, forKey: "id")
                }
            }
            
            public var details: String? {
                get {
                    return resultMap["details"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "details")
                }
            }
            
            public var launchDateLocal: String? {
                get {
                    return resultMap["launch_date_local"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "launch_date_local")
                }
            }
            
            public var launchSite: LaunchSite? {
                get {
                    return (resultMap["launch_site"] as? ResultMap).flatMap { LaunchSite(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "launch_site")
                }
            }
            
            public var links: Link? {
                get {
                    return (resultMap["links"] as? ResultMap).flatMap { Link(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "links")
                }
            }
            
            public var rocket: Rocket? {
                get {
                    return (resultMap["rocket"] as? ResultMap).flatMap { Rocket(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "rocket")
                }
            }
            
            public struct LaunchSite: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["LaunchSite"]
                
                public static var selections: [GraphQLSelection] {
                    return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("site_name_long", type: .scalar(String.self)),
                    ]
                }
                
                public private(set) var resultMap: ResultMap
                
                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }
                
                public init(siteNameLong: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "LaunchSite", "site_name_long": siteNameLong])
                }
                
                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }
                
                public var siteNameLong: String? {
                    get {
                        return resultMap["site_name_long"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "site_name_long")
                    }
                }
            }
            
            public struct Link: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["LaunchLinks"]
                
                public static var selections: [GraphQLSelection] {
                    return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("video_link", type: .scalar(String.self)),
                        GraphQLField("flickr_images", type: .list(.scalar(String.self))),
                    ]
                }
                
                public private(set) var resultMap: ResultMap
                
                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }
                
                public init(videoLink: String? = nil, flickrImages: [String?]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "LaunchLinks", "video_link": videoLink, "flickr_images": flickrImages])
                }
                
                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }
                
                public var videoLink: String? {
                    get {
                        return resultMap["video_link"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "video_link")
                    }
                }
                
                public var flickrImages: [String?]? {
                    get {
                        return resultMap["flickr_images"] as? [String?]
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "flickr_images")
                    }
                }
            }
            
            public struct Rocket: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["LaunchRocket"]
                
                public static var selections: [GraphQLSelection] {
                    return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("rocket_name", type: .scalar(String.self)),
                    ]
                }
                
                public private(set) var resultMap: ResultMap
                
                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }
                
                public init(rocketName: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "LaunchRocket", "rocket_name": rocketName])
                }
                
                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }
                
                public var rocketName: String? {
                    get {
                        return resultMap["rocket_name"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "rocket_name")
                    }
                }
            }
        }
    }
}
