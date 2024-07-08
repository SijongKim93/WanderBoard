//
//  AccountDeletionManager.swift
//  WanderBoard
//
//  Created by Luz on 6/15/24.
//

import Foundation
import FirebaseAuth
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

final class AccountDeletionManager {
    static let shared = AccountDeletionManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private init() { }
    
    
    // 7월 2일 추가: 회원 탈퇴 시 관련 이미지를 삭제하는 기능 추가
    private func deleteImages(from pinLogs: [PinLog]) async throws {
        for pinLog in pinLogs {
            for media in pinLog.media {
                let storageRef = storage.reference(forURL: media.url)
                do {
                    try await storageRef.delete()
                } catch {
                    print("Failed to delete image: \(error)")
                    throw error
                }
            }
        }
    }
    
    // 사용자의 데이터를 Firestore에서 삭제하는 함수 (회원 탈퇴)
    func deleteUserData(uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.delete()
    }
    
    // 회원 탈퇴 시 특정 사용자의 모든 PinLog 데이터를 삭제하는 함수
    // 7월 2일 변경: 회원 탈퇴 시 핀로그와 함께 이미지를 먼저 삭제하도록 수정
    func deletePinLogsForUser(userId: String) async throws {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        let pinLogs = snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
        try await deleteImages(from: pinLogs)
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    // 특정 사용자가 참여한 PinLog에서 해당 사용자 ID를 삭제하는 함수
    func removeUserIdFromPinLogs(userId: String) async throws {
        // attendeeIds에서 사용자 ID를 포함하는 문서 찾기
        let attendeeSnapshot = try await db.collection("pinLogs").whereField("attendeeIds", arrayContains: userId).getDocuments()
        for document in attendeeSnapshot.documents {
            var data = document.data()
            if var attendeeIds = data["attendeeIds"] as? [String] {
                attendeeIds.removeAll { $0 == userId }
                data["attendeeIds"] = attendeeIds
            }
            try await document.reference.setData(data, merge: true)
        }
        
        // pinnedBy에서 사용자 ID를 포함하는 문서 찾기
        let pinnedBySnapshot = try await db.collection("pinLogs").whereField("pinnedBy", arrayContains: userId).getDocuments()
        for document in pinnedBySnapshot.documents {
            var data = document.data()
            if var pinnedBy = data["pinnedBy"] as? [String] {
                pinnedBy.removeAll { $0 == userId }
                data["pinnedBy"] = pinnedBy
            }
            try await document.reference.setData(data, merge: true)
        }
    }
    
    // Core Data에서 사용자 데이터를 삭제하는 함수
    func deleteUserFromCoreData(userId: String, context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uid == %@", userId)

        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
        } catch {
            throw error
        }
    }

    // 전체 사용자 데이터 삭제 함수
    func deleteUser(uid: String, context: NSManagedObjectContext) async throws {
        // 사용자 데이터를 삭제하는 모든 작업이 성공적으로 완료된 경우에만 계정 삭제
        do {
            try await deleteUserData(uid: uid)
            try await deletePinLogsForUser(userId: uid)
            try await removeUserIdFromPinLogs(userId: uid)
            try deleteUserFromCoreData(userId: uid, context: context)
            print("모든 사용자 데이터 삭제 성공")
        } catch {
            print("사용자 데이터 삭제 중 오류 발생: \(error.localizedDescription)")
            throw error
        }
    }
}
