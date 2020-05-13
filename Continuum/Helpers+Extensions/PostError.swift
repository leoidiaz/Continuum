//
//  PostError.swift
//  Continuum
//
//  Created by Leonardo Diaz on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation

enum PostError: LocalizedError{
    case noPhotoSelected
    case noCaption
    case noCommentText
    
    var errorDescription: String? {
        switch self {
        case .noPhotoSelected:
            return "You need to add a photo!"
        case .noCaption:
            return "Looks like you forgot to add a caption a long with your art."
        case .noCommentText:
            return "Be sure to put some words with that comment!"
        }
    }
}
