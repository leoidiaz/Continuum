//
//  UIViewControllerExtensions.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentErrorToUser(localizedError: PostError) {
        let alertController = UIAlertController(title: "GAWRSH!", message: localizedError.errorDescription, preferredStyle: .actionSheet)
        
        let dismissAction = UIAlertAction(title: "sigh", style: .cancel)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
}
