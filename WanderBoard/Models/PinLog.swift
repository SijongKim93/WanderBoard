//
//  PinLog.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct Media: Codable {
    var url: String
    var latitude: Double?
    var longitude: Double?
    var dateTaken: Date?
    var isRepresentative: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        dateTaken = try container.decodeIfPresent(Date.self, forKey: .dateTaken)
        isRepresentative = try container.decodeIfPresent(Bool.self, forKey: .isRepresentative) ?? false
    }
    
    init(url: String, latitude: Double?, longitude: Double?, dateTaken: Date?, isRepresentative: Bool = false) {
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        self.dateTaken = dateTaken
        self.isRepresentative = isRepresentative
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["url": url, "isRepresentative": isRepresentative]
        if let latitude = latitude {
            dict["latitude"] = latitude
        }
        if let longitude = longitude {
            dict["longitude"] = longitude
        }
        if let dateTaken = dateTaken {
            dict["dateTaken"] = Timestamp(date: dateTaken)
        }
        return dict
    }
}

struct Expense: Codable, Equatable {
    var id: String?
    var date: Date
    var expenseContent: String
    var expenseAmount: Int
    var category: String
    var memo: String
    var imageName: String
    
    
    func toDictionary() -> [String: Any] {
        return [
            "id": self.id ?? UUID().uuidString,
            "date": Timestamp(date: self.date),
            "expenseContent": self.expenseContent,
            "expenseAmount": self.expenseAmount,
            "category": self.category,
            "memo": self.memo,
            "imageName": self.imageName
        ]
    }
}

struct DailyExpenses: Codable {
    var date: Date
    var expenses: [Expense]
    
    func toDictionary() -> [String: Any] {
        return [
            "date": Timestamp(date: self.date),
            "expenses": self.expenses.map { $0.toDictionary() }
        ]
    }
}

struct PinLog: Identifiable, Codable {
    @DocumentID var id: String?
    var location: String
    var address: String
    var latitude: Double
    var longitude: Double
    var startDate: Date
    var endDate: Date
    var duration: Int
    var title: String
    var content: String
    var media: [Media]
    var authorId: String
    var attendeeIds: [String]
    var isPublic: Bool
    var createdAt: Date?
    var pinCount: Int?
    var pinnedBy: [String]?
    var totalSpendingAmount: Int?
    var isSpendingPublic: Bool
    var maxSpendingAmount: Int?
    var expenses: [DailyExpenses]?
    
    init(id: String? = nil, location: String, address: String, latitude: Double, longitude: Double, startDate: Date, endDate: Date, title: String, content: String, media: [Media], authorId: String, attendeeIds: [String], isPublic: Bool, createdAt: Date?, pinCount:Int?, pinnedBy: [String]? = [],  totalSpendingAmount: Int?, isSpendingPublic: Bool, maxSpendingAmount: Int?, expenses: [DailyExpenses]? = nil) {
        
        self.id = id
        self.location = location
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.startDate = startDate
        self.endDate = endDate
        self.duration = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        self.title = title
        self.content = content
        self.media = media
        self.authorId = authorId
        self.attendeeIds = attendeeIds
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.pinCount = pinCount //핀 갯수 추가 - 한빛
        self.pinnedBy = pinnedBy // 핀 상태 확인 - 한빛
        self.totalSpendingAmount = totalSpendingAmount ?? 0//핀로그당 사용한 최종금액 - 시안
        self.isSpendingPublic = isSpendingPublic
        self.maxSpendingAmount = maxSpendingAmount ?? 0
        self.expenses = expenses // 지출 데이터 추가 (옵셔널)
    }
}
