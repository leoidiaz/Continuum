//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    //MARK: - Properties
    private let reuseIdentifier = "postCell"
    private let segueIdentifier = "toDetailVC"
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell()}
        let post = PostController.shared.posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow, let destinationVC = segue.destination as? PostDetailTableViewController else { return }
            let post = PostController.shared.posts[indexPath.row]
            destinationVC.post = post
        }
    }
}
