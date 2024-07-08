//
//  PinLogManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/31/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import CoreLocation

class PinLogManager {
    static let shared = PinLogManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private func saveDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        do {
            try await documentRef.setData(data)
        } catch {
            throw error
        }
    }

    private func updateDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        do {
            try await documentRef.updateData(data)
        } catch {
            throw error
        }
    }
    
    // 7월 2일 추가: 핀로그 삭제 시 관련 이미지를 삭제하는 기능 추가
    func deleteImages(from pinLog: PinLog) async throws {
        let storage = Storage.storage()
        for media in pinLog.media {
            let storageRef = storage.reference(forURL: media.url)
            do {
                try await storageRef.delete()
            } catch let error as NSError {
                if let errorCode = StorageErrorCode(rawValue: error.code), errorCode == .objectNotFound {
                    print("Object \(media.url) does not exist.")
                    // Continue with the next image
                    continue
                } else {
                    print("Failed to delete image: \(error)")
                    throw error
                }
            }
        }
    }
    
    func createOrUpdatePinLog(pinLog: inout PinLog, images: [UIImage], imageLocations: [CLLocationCoordinate2D], isRepresentativeFlags: [Bool]) async throws -> PinLog {
        var mediaObjects: [Media] = []
        
        for (index, image) in images.enumerated() {
            do {
                let isRepresentative = isRepresentativeFlags[index]
                var media = try await StorageManager.shared.uploadImage(image: image, userId: pinLog.authorId, isRepresentative: isRepresentative)
                if index < imageLocations.count {
                    media.latitude = imageLocations[index].latitude
                    media.longitude = imageLocations[index].longitude
                }
                mediaObjects.append(media)
            } catch {
                print("Failed to upload image: \(error)")
                throw error
            }
        }
        
        let mediaData = mediaObjects.map { $0.toDictionary() }
        var expensesData: [[String: Any]] = []
        if let expenses = pinLog.expenses {
            for dailyExpense in expenses {
                var expenseArray: [[String: Any]] = []
                for var expense in dailyExpense.expenses {
                    if expense.id == nil || expense.id!.isEmpty {
                        expense.id = UUID().uuidString
                    }
                    expenseArray.append(expense.toDictionary())
                }
                expensesData.append([
                    "date": Timestamp(date: dailyExpense.date),
                    "expenses": expenseArray
                ])
            }
        }
        
        let documentId = pinLog.id ?? UUID().uuidString
        let documentRef = db.collection("pinLogs").document(documentId)
        
        let data: [String: Any] = [
            "location": pinLog.location,
            "address": pinLog.address,
            "latitude": pinLog.latitude,
            "longitude": pinLog.longitude,
            "startDate": Timestamp(date: pinLog.startDate),
            "endDate": Timestamp(date: pinLog.endDate),
            "duration": pinLog.duration,
            "title": pinLog.title,
            "content": pinLog.content,
            "media": mediaData,
            "authorId": pinLog.authorId,
            "attendeeIds": pinLog.attendeeIds,
            "isPublic": pinLog.isPublic,
            "createdAt": Timestamp(date: pinLog.createdAt ?? Date()),
            "pinCount": pinLog.pinCount ?? 0,
            "pinnedBy": pinLog.pinnedBy ?? [],
            "totalSpendingAmount": pinLog.totalSpendingAmount ?? 0.0,
            "isSpendingPublic": pinLog.isSpendingPublic,
            "maxSpendingAmount": pinLog.maxSpendingAmount ?? 0,
            "expenses": expensesData
        ]
        
        if pinLog.id == nil {
            try await saveDocument(documentRef: documentRef, data: data)
            pinLog.id = documentId
        } else {
            try await updateDocument(documentRef: documentRef, data: data)
        }
        
        return pinLog
    }
    
    // 7월 2일 변경: 핀로그 삭제 시 이미지를 먼저 삭제하도록 수정
    func deletePinLog(pinLogId: String) async throws {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        do {
            try await documentRef.delete()
            print("Pin log \(pinLogId) deleted successfully.")
        } catch {
            print("Failed to delete pin log: \(error.localizedDescription)")
            throw error
        }
    }
    
    //디테일뷰에 아이디로 데이터 가져오기
    func fetchPinLog(by id: String, completion: @escaping (Result<PinLog, Error>) -> Void) {
        let documentRef = db.collection("pinLogs").document(id)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                do {
                    let pinLog = try document.data(as: PinLog.self)
                    completion(.success(pinLog))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "PinLog not found", code: 404, userInfo: nil)))
            }
        }
    }
    
    func fetchSpendingPublicPinLogs() async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs")
            .whereField("isSpendingPublic", isEqualTo: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
    
    //MARK: - Explore, SearchViewController 관련 함수

    func fetchHotPinLogs() async throws -> [PinLogSummary] {
        let snapshot = try await db.collection("pinLogs")
            .whereField("pinCount", isGreaterThan: 4)
            .whereField("isPublic", isEqualTo: true)
            .getDocuments()
        
        let allDocuments = snapshot.documents
        guard !allDocuments.isEmpty else {
            return []
        }
        let randomDocuments = allDocuments.shuffled().prefix(10)
        
        return randomDocuments.compactMap { document in
            let data = document.data()
            let location = data["location"] as? String ?? ""
            let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
            let representativeMediaURL = (data["media"] as? [[String: Any]])?.first { $0["isRepresentative"] as? Bool == true }?["url"] as? String
            let authorId = data["authorId"] as? String ?? ""
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let isPublic = data["isPublic"] as? Bool ?? false
            
            return PinLogSummary(id: document.documentID, location: location, startDate: startDate, representativeMediaURL: representativeMediaURL, authorId: authorId, createdAt: createdAt, isPublic: isPublic)
        }
    }
    
    func fetchInitialData(pageSize: Int, completion: @escaping (Result<([PinLogSummary], DocumentSnapshot?), Error>) -> Void) {
        db.collection("pinLogs")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    var pinLogSummaries: [PinLogSummary] = []
                    var lastDocumentSnapshot: DocumentSnapshot? = nil

                    for document in snapshot!.documents {
                        let data = document.data()
                        let representativeMediaURL = (data["media"] as? [[String: Any]])?.first { $0["isRepresentative"] as? Bool == true }?["url"] as? String

                        let pinLogSummary = PinLogSummary(
                            id: document.documentID,
                            location: data["location"] as? String ?? "",
                            startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                            representativeMediaURL: representativeMediaURL,
                            authorId: data["authorId"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            isPublic: data["isPublic"] as? Bool ?? false
                        )
                        pinLogSummaries.append(pinLogSummary)
                    }

                    lastDocumentSnapshot = snapshot!.documents.last
                    completion(.success((pinLogSummaries, lastDocumentSnapshot)))
                }
            }
    }
    
    func fetchMoreData(pageSize: Int, lastSnapshot: DocumentSnapshot, completion: @escaping (Result<([PinLogSummary], DocumentSnapshot?), Error>) -> Void) {
        db.collection("pinLogs")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastSnapshot)
            .limit(to: pageSize)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    var pinLogSummaries: [PinLogSummary] = []
                    var lastDocumentSnapshot: DocumentSnapshot? = nil

                    for document in snapshot!.documents {
                        let data = document.data()
                        let representativeMediaURL = (data["media"] as? [[String: Any]])?.first { $0["isRepresentative"] as? Bool == true }?["url"] as? String

                        let pinLogSummary = PinLogSummary(
                            id: document.documentID,
                            location: data["location"] as? String ?? "",
                            startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                            representativeMediaURL: representativeMediaURL,
                            authorId: data["authorId"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            isPublic: data["isPublic"] as? Bool ?? false
                        )
                        pinLogSummaries.append(pinLogSummary)
                    }

                    lastDocumentSnapshot = snapshot!.documents.last
                    completion(.success((pinLogSummaries, lastDocumentSnapshot)))
                }
            }
    }
    
    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        let pinLogs = snapshot.documents.compactMap { document -> PinLog? in
            do {
                let pinLog = try document.data(as: PinLog.self)
                //print("Fetched pinLog: \(pinLog)")
                return pinLog
            } catch {
                print("Error decoding document: \(document.documentID), error: \(error)")
                return nil
            }
        }
        return pinLogs
    }
    
    // 핀 찍은 데이터만 가져오기
    func fetchPinnedPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let querySnapshot = try await db.collection("pinLogs")
            .whereField("pinnedBy", arrayContains: userId)
            .whereField("isPublic", isEqualTo: true)
            .getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: PinLog.self)
        }
    }
    
    //태그된 데이터만 가져오기
    func fetchTaggedPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let querySnapshot = try await db.collection("pinLogs")
            .whereField("attendeeIds", arrayContains: userId)
            .whereField("isPublic", isEqualTo: true)
            .getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: PinLog.self)
        }
    }
}
