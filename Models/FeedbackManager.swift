//
//  FeedbackManager.swift
//  HIG
//
//  Manages feedback ratings persistence
//

import Foundation

// MARK: - Feedback Manager

@MainActor
class FeedbackManager {
    static let shared = FeedbackManager()
    
    private let userDefaults = UserDefaults.standard
    private let ratingsKey = "feedbackRatings"
    
    private init() {}
    
    // MARK: - Save Rating
    
    func saveRating(messageId: UUID, rating: ChatMessage.FeedbackRating) {
        var ratings = loadAllRatings()
        ratings[messageId.uuidString] = rating.rawValue
        
        if let encoded = try? JSONEncoder().encode(ratings) {
            userDefaults.set(encoded, forKey: ratingsKey)
        }
    }
    
    // MARK: - Load Rating
    
    func loadRating(messageId: UUID) -> ChatMessage.FeedbackRating? {
        let ratings = loadAllRatings()
        guard let ratingString = ratings[messageId.uuidString],
              let rating = ChatMessage.FeedbackRating(rawValue: ratingString) else {
            return nil
        }
        return rating
    }
    
    // MARK: - Load All Ratings
    
    func loadAllRatings() -> [String: String] {
        guard let data = userDefaults.data(forKey: ratingsKey),
              let ratings = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return ratings
    }
    
    // MARK: - Clear Ratings
    
    func clearAllRatings() {
        userDefaults.removeObject(forKey: ratingsKey)
    }
}
