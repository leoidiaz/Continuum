//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Properties
    private let reuseIdentifier = "commentsCell"
    var post: Post? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        guard let post = post else { return }
        let alertController = UIAlertController(title: "Add a Comment", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Comment Here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addCommentAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let commentText = alertController.textFields?.first?.text, !commentText.isEmpty else { return }
            PostController.shared.addComment(text: commentText, post: post) { (comment) in
            }
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addCommentAction)
        present(alertController, animated: true)
    }
    
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post, let photo = post.photo else { return }
        let activityController = UIActivityViewController(activityItems: [photo, post.caption], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
    }
    
    //MARK: - Private Methods
    private func updateViews(){
        guard let post = post else { return }
        photoImageView.image = post.photo
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let post = post else { return UITableViewCell() }
        let postComments = post.comments[indexPath.row]
        cell.textLabel?.text = postComments.text
        cell.detailTextLabel?.text = postComments.timestamp.format()
        return cell
    }


}
