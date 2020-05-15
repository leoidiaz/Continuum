//
//  Comment.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let recordTypeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let referenceKey = "post"
}

class Comment: SearchableRecord {
    
    var text: String
    var timestamp: Date
    weak var post: Post?
    var recordID: CKRecord.ID
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, timestamp: Date = Date(), post: Post?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.post = post
    }
    
    //MARK: - Searchable Record Delegate
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
    
}

extension Comment {
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else { return nil }
        self.init(text: text, timestamp: timestamp, post: post, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentConstants.recordTypeKey, recordID: comment.recordID)
        setValuesForKeys([
            CommentConstants.textKey : comment.text,
            CommentConstants.timestampKey : comment.timestamp,
            CommentConstants.referenceKey : comment.postReference
        ])
    }
}
