//
//  InfoModel.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

struct InfoModel: Codable {
    let title: String
    let rows: [Row]
}

struct Row: Codable {
    let title, description: String?
    let imageHref: String?
}
