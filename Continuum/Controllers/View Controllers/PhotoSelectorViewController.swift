//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/13/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: class {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectImageTapped: UIButton!
    //MARK: - Properties
    weak var delegate: PhotoSelectorViewControllerDelegate?
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoImageView.image = nil
        self.selectImageTapped.setTitle("Select Photo", for: .normal)
    }
    
    //MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        presentActionSheetController()
    }
    
    //MARK: - Helper methods
    private func presentActionSheetController(){
        let alertController = UIAlertController(title: "Select an Image", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePicker, animated: true)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true)
            }))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
}

extension PhotoSelectorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let photo = info[.originalImage] as? UIImage else { return }
        selectImageTapped.setTitle("", for: .normal)
        photoImageView.image = photo
        delegate?.photoSelectorViewControllerSelected(image: photo)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
}

