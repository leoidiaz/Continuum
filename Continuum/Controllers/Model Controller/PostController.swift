//
//  PostController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostController {
    
    static let shared = PostController()
    var posts = [Post]()
    
    
    
    func addComment(text: String, post: Post, completion: @escaping (Result <Comment, PostError>) -> Void){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
    func createPostWith(postImage: UIImage, caption: String, completion: @escaping(Result <Post?, PostError>) -> Void){
        let newPost = Post(caption: caption, photo: postImage)
        posts.append(newPost)
    }
}
