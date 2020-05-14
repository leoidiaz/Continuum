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
    case noAccount
    case unexpectedError
    case restrictedError
    case newError
    case ckError(Error)
    case couldNotUnwrap
    
    
    var errorDescription: String? {
        switch self {
        case .couldNotUnwrap:
            return "Unable to retrieve this post"
        case .ckError(let error):
            return error.localizedDescription
        case .noAccount:
            return "No account found"
        case .unexpectedError:
            return "There was an unknown error fetching your iCloud Account"
        case .restrictedError:
            return "Your iCloud account is restricted"
        case .newError:
            return "Apple added something new and we haven't updated. Reach out to us."
        case .noPhotoSelected:
            return "You need to add a photo!"
        case .noCaption:
            return "Looks like you forgot to add a caption a long with your art."
        case .noCommentText:
            return "Be sure to put some words with that comment!"
        }
    }
}
