//
//  Model.swift
//  MapKitTest
//
//  Created by JIN on 18/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import Foundation

struct APIResponse: Codable {
    let status: String
    let meta: [Meta]
    let places: [Place]
    let errorMessage: String
}

struct Meta: Codable {
    let totalCount: Int
    let count: Int
}

struct Place: Codable {
    let name: String
    let road_adress: String
    let jibun_address: String
    let phone_number: String
    let x, y : String
    let distance: Int
    let sessionId: String
}
