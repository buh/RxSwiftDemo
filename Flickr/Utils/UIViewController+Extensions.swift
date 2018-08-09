//
//  UIViewController+Extensions.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 27/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Show an alert with error message.
    func showAlert(error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        
        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in retryHandler() }))
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        present(alertController, animated: true)
    }
}
