//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    //MARK: - Properties
    private let reuseIdentifier = "addPostCell"
    
    //MARK: - Outlets
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        postImageView.image = nil
        captionTextField.text = ""
        selectImageButton.setTitle("Select Image", for: .normal)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        postImageView.image = #imageLiteral(resourceName: "spaceEmptyState")
        selectImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let postImage = postImageView.image, let caption = captionTextField.text else { return }
        PostController.shared.createPostWith(postImage: postImage, caption: caption) { (_) in
        }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
}
