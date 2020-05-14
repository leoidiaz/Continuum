//
//  PostController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    static let shared = PostController()
    var posts = [Post]()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func addComment(text: String, post: Post, completion: @escaping (Result <Comment, PostError>) -> Void){
        let newComment = Comment(text: text, post: post)
        let commentRecord = CKRecord(comment: newComment)
        publicDB.save(commentRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record, let savedComment = Comment(ckRecord: record, post: post) else {
                print("Could not unwrap record")
                return completion(.failure(.couldNotUnwrap))
            }
            print("Success saving the comment boss")
            completion(.success(savedComment))
            post.comments.append(newComment)
        }
    }
    
    func createPostWith(postImage: UIImage?, caption: String, completion: @escaping(Result <Post?, PostError>) -> Void){
        let newPost = Post(caption: caption, photo: postImage)
        let postRecord = CKRecord(post: newPost)
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record, let savedPost = Post(ckRecord: record) else {
                print("Could not unwrap record")
                return completion(.failure(.couldNotUnwrap))
            }
            print("Success Saving the post boss")
            completion(.success(savedPost))
            self.posts.append(newPost)
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping([Comment]?)-> Void){
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.referenceKey, postReference)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: CommentConstants.recordTypeKey, predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
            guard let records = records else { return completion(nil)}
            let comments = records.compactMap({Comment(ckRecord: $0, post: post)})
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
    }
    
    func fetchPosts(completion: @escaping([Post]?) -> Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(nil)
            }
            guard let records = records else { return completion(nil)}
            
            let posts = records.compactMap({Post(ckRecord: $0)})
            self.posts = posts
            completion(posts)
            
        }
    }
    
    func incrementCommentCount(post: Post, completion:((Bool)-> Void)?) {
        post.commentCount += 1
        let operation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
        publicDB.add(operation)
    }
}
