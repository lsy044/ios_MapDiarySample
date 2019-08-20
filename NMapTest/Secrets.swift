//
//  Secrets.swift
//  NMapTest
//
//  Created by JIN on 20/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import Foundation

struct APIKey: Codable {
    let clientID: String = ""
    let clientSecret: String = ""
}

let ApiKey: [String:String] = ["X-NCP-APIGW-API-KEY-ID": "","X-NCP-APIGW-API-KEY":""]

