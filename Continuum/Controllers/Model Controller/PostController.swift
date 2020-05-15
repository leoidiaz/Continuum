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
    init() {
        subscribeToNewPosts(completion: nil)
    }
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
            self.incrementCommentCount(post: post, completion: nil)
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
                return completion(nil)
            }
            guard let records = records else { return completion(nil)}
            let comments = records.compactMap({Comment(ckRecord: $0, post: post)})
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
    }
    
    func fetchPosts(completion: @escaping(Result<[Post]?, PostError>) -> Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            
            let posts = records.compactMap{ Post(ckRecord: $0) }
            
            self.posts = posts
            
            completion(.success(posts))
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
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?){
        let predicate = NSPredicate(value: true)
        let querySubscription = CKQuerySubscription(recordType: PostConstants.typeKey, predicate: predicate, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "New Post Added"
        notification.shouldBadge = true
        notification.shouldSendContentAvailable = true
        querySubscription.notificationInfo = notification
        
        publicDB.save(querySubscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func subscribeToNewComments(post: Post, completion:((Bool, Error?) -> Void)?){
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.referenceKey, post.recordID)
        let querySubscription = CKQuerySubscription(recordType: CommentConstants.recordTypeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let commentNotfication = CKSubscription.NotificationInfo()
        commentNotfication.alertBody = "New Comment Added"
        commentNotfication.shouldBadge = true
        commentNotfication.shouldSendContentAvailable = true
        querySubscription.notificationInfo = commentNotfication
        
        publicDB.save(querySubscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
            
        }
    }
    
    func removeSubscriptionFrom(post: Post, completion:((Bool) -> Void)?){
        let subID = post.recordID.recordName
        publicDB.delete(withSubscriptionID: subID) { (_, error) in
            if let error = error{
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
    }
    
    func checkForSubscription(post: Post, completion: ((Bool) -> Void)?){
        let subID = post.recordID.recordName
        publicDB.fetch(withSubscriptionID: subID) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                //                completion?(false)
            }
            
            if subscription != nil{
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscription(post: Post, completion: ((Bool, Error?) -> Void)?){
        checkForSubscription(post: post) { (subscriptionStatus) in
            if subscriptionStatus{
                self.removeSubscriptionFrom(post: post) { (success) in
                    if success {
                        print("Unsubscribe successful!")
                        completion?(false, nil)
                    } else {
                        print("Error unsubscribing here")
                        completion?(true, nil)
                    }
                }
            } else {
                self.subscribeToNewComments(post: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        completion?(false, error)
                        return
                    }
                    if success {
                        print("Successfully subscribed!")
                        completion?(true, nil)
                        return
                    } else {
                        print("Error subscribing here")
                        completion?(false, nil)
                    }
                }
            }
        }
    }
}
