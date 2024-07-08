//
//  User.swift
//  WanderBoard
//
//  Created by David Jang on 6/7/24.
//

import Foundation
import CoreData

struct User: Codable {
    let uid: String
    let email: String
    var displayName: String
    var photoURL: String?
    var gender: String?
    var interests: [String]?
    var socialMediaLink: String?
    var authProvider: String?
    var isProfileComplete: Bool?
    var blockedAuthors: [String]?
    var myPinCount: Int?
    var agreedToTerms: Bool?
    var agreedToPrivacyPolicy: Bool?
    var agreedToMarketing: Bool?
    var agreedToThirdParty: Bool?
    var joinedDate: Date?
    var hiddenPinLogs: [String]?

    init(entity: UserEntity) {
        self.uid = entity.uid ?? ""
        self.email = entity.email ?? ""
        self.displayName = entity.displayName ?? ""
        self.photoURL = entity.photoURL
        self.gender = entity.gender ?? ""
        self.interests = (entity.interests?.jsonArray() as? [String]) ?? []
        self.socialMediaLink = entity.socialMediaLink
        self.authProvider = entity.authProvider ?? ""
        self.isProfileComplete = entity.isProfileComplete
        self.blockedAuthors = (entity.blockedAuthors?.jsonArray() as? [String]) ?? []
        self.myPinCount = Int(entity.myPinCount)
        self.agreedToTerms = entity.agreedToTerms
        self.agreedToPrivacyPolicy = entity.agreedToPrivacyPolicy
        self.agreedToMarketing = entity.agreedToMarketing
        self.agreedToThirdParty = entity.agreedToThirdParty
        self.joinedDate = entity.joinedDate
        self.hiddenPinLogs = (entity.hiddenPinLogs?.jsonArray() as? [String]) ?? []
    }

    func toUserEntity(context: NSManagedObjectContext) -> UserEntity {
        let userEntity = UserEntity(context: context)
        userEntity.uid = self.uid
        userEntity.email = self.email
        userEntity.displayName = self.displayName
        userEntity.photoURL = self.photoURL
        userEntity.gender = self.gender
        userEntity.interests = self.interests?.jsonString() ?? "[]"
        userEntity.socialMediaLink = self.socialMediaLink
        userEntity.authProvider = self.authProvider
        if let isProfileComplete = self.isProfileComplete {
            userEntity.isProfileComplete = isProfileComplete
        }
        userEntity.blockedAuthors = self.blockedAuthors?.jsonString() ?? "[]"
        userEntity.myPinCount = Int64(self.myPinCount ?? 0)
        userEntity.agreedToTerms = self.agreedToTerms ?? false
        userEntity.agreedToPrivacyPolicy = self.agreedToPrivacyPolicy ?? false
        userEntity.agreedToMarketing = self.agreedToMarketing ?? false
        userEntity.agreedToThirdParty = self.agreedToThirdParty ?? false
        userEntity.joinedDate = self.joinedDate
        userEntity.hiddenPinLogs = self.hiddenPinLogs?.jsonString() ?? "[]"
        return userEntity
    }
}

extension Array where Element == String {
    func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        return jsonData.flatMap { String(data: $0, encoding: .utf8) }
    }
}

extension String {
    func jsonArray() -> [Any]? {
        let jsonData = self.data(using: .utf8)
        return jsonData.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [Any] }
    }
}
