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
    private let segueIdentifier = "toPhotoSelectorVC"
    var selectedImage: UIImage?
    
    //MARK: - Outlets
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captionTextField.text = ""
    }
    
    //MARK: - Actions
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let postImage = selectedImage else { return presentErrorToUser(localizedError: .noPhotoSelected)}
        guard let caption = captionTextField.text, !caption.isEmpty else { return presentErrorToUser(localizedError: .noCaption)}
        PostController.shared.createPostWith(postImage: postImage, caption: caption) { (_) in
        }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
}

//MARK: - PhotoSelector Delegate
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate{
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    } 
}
//MARK: - UITextfield Delegate
extension AddPostTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
    }
}
