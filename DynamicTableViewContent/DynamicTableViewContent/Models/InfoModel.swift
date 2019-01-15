//
//  InfoModel.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

//  Model for service data called for View Controller
struct InfoModel: Codable {
    let title: String
    let rows: [Row]
}
//  Model for service data called for View Controller
struct Row: Codable {
    let title, description: String?
    let imageHref: String?
}
