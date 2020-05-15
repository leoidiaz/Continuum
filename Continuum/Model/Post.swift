//
//  Post.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct PostConstants {
    static let typeKey = "Post"
    static let captionKey = "caption"
    static let timestampKey = "timestamp"
    static let commentsKey = "comments"
    static let photoKey = "photo"
    static let commentCountKey = "commentCount"
}

class Post:SearchableRecord {
    
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    var commentCount: Int
    
    var photo: UIImage? {
        get{
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var photoData: Data?
    var recordID: CKRecord.ID
    var imageAsset: CKAsset?{
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(timestamp: Date = Date(), caption: String, comments: [Comment] = [], photo: UIImage?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.recordID = recordID
        self.commentCount = commentCount
        self.photo = photo
    }
    
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()){
            return true
        } else {            
            for comment in comments {
                if comment.matches(searchTerm: searchTerm) {
                    return true
                }
            }
        }
        return false
    }
}

extension CKRecord {
    convenience init(post: Post){
        self.init(recordType: PostConstants.typeKey, recordID: post.recordID)
        setValuesForKeys([
            PostConstants.captionKey : post.caption,
            PostConstants.timestampKey: post.timestamp,
            PostConstants.commentCountKey : post.commentCount,
            PostConstants.photoKey : post.imageAsset
        ])
    }
}

extension Post {
    convenience init?(ckRecord: CKRecord){
        guard let caption = ckRecord[PostConstants.captionKey] as? String,
            let timestamp = ckRecord[PostConstants.timestampKey] as? Date,
            let commentCount = ckRecord[PostConstants.commentCountKey] as? Int else { return nil }
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[PostConstants.photoKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        self.init(timestamp: timestamp, caption: caption, photo: foundPhoto, recordID: ckRecord.recordID, commentCount: commentCount)
    }
}
