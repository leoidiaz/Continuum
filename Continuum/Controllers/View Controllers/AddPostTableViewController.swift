//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //MARK: - Properties
    private let reuseIdentifier = "addPostCell"
    private let segueIdentifier = "toPhotoSelectorVC"
    var selectedImage: UIImage?
    
    //MARK: - Outlets
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captionTextField.text = ""
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let postImage = selectedImage, let caption = captionTextField.text else { return }
        PostController.shared.createPostWith(postImage: postImage, caption: caption) { (_) in
        }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
    
}

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate{
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    } 
}

