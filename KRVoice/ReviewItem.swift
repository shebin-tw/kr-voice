//
//  ReviewItem.swift
//  KRVoice
//
//  Created by Shebin Koshy on 18/04/22.
//

import Foundation

let reviewsUserDefautlsKey = "reviewsUserDefautlsKey"

struct ReviewItem {
    let uniqueId: String
    let revDescription: String
    let rating: Int
    let ownerName: String
    
    private func dict() -> [String: String] {
        var dict = [String: String]()
        dict["uniqueId"] = uniqueId
        dict["revDescription"] = revDescription
        dict["rating"] = "\(rating)"
        dict["ownerName"] = ownerName
        return dict
    }
    
    static func fetchReviews() -> [ReviewItem]? {
        guard let arrayOfDict = UserDefaults.standard.object(forKey: reviewsUserDefautlsKey) as? [[String: String]] else {
            return nil
        }
        let reviews = reviewsFromArrayOfDict(arrayOfDict: arrayOfDict)
        return reviews
    }
    
    static func saveReview(review: ReviewItem) {
        var arrayOfDict = UserDefaults.standard.object(forKey: reviewsUserDefautlsKey) as? [[String: String]]
        if arrayOfDict == nil {
            arrayOfDict = [[String: String]]()
        }
        arrayOfDict?.append(review.dict())
        UserDefaults.standard.set(arrayOfDict,forKey: reviewsUserDefautlsKey)
    }
    
    static func reviewsArrayOfDictFromInstances(arrayOfInstances: [ReviewItem]) -> [[String:String]] {
        var arrayOfDict = [[String: String]]()
        for review in arrayOfInstances {
            arrayOfDict.append(review.dict())
        }
        return arrayOfDict
    }
    
    static func reviewsFromArrayOfDict(arrayOfDict: [[String: String]]) -> [ReviewItem] {
        var reviews = [ReviewItem]()
        for dict in arrayOfDict {
            guard let uniqueId = dict["uniqueId"] else {
                continue
            }
            guard let revDescription = dict["revDescription"] else {
                continue
            }
            guard let rating = dict["rating"] else {
                continue
            }
            let ownerName = dict["ownerName"]
            let item = ReviewItem(uniqueId: uniqueId, revDescription: revDescription, rating: NumberFormatter().number(from: rating)?.intValue ?? 0, ownerName: ownerName ?? "")
            reviews.append(item)
        }
        return reviews
    }
}
