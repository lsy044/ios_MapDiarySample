import Foundation

struct PlaceResponse: Codable {
    let status: String?
    let meta: Meta?
    let places: [Place]?
    let errorMessage: String?
}

struct Meta: Codable {
    let totalCount, count: Int?
}

struct Place: Codable {
    let name, roadAddress, jibunAddress, phoneNumber: String?
    let x, y: String?
    let distance: Double? //String x
    let sessionID: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case roadAddress = "road_address"
        case jibunAddress = "jibun_address"
        case phoneNumber = "phone_number"
        case x, y, distance
        case sessionID
    }
}
